############################################################
# Dockerfile to build Apollo Cloud on Raspberry Pi (Armv7hf)
############################################################

# Set the base image
FROM jsurf/rpi-raspbian:latest

# Runs a a cross build script that allows Docker Hub to build the image
RUN [ "cross-build-start" ]

ENV LANG C.UTF-8 
ENV TZ Europe/Berlin



RUN echo "deb http://archive.raspberrypi.org/debian/ jessie main" >> /etc/apt/sources.list.d/raspberrypi.list \
 && apt-get update \
 && apt-get purge wolfram* \
 && apt-get install -f -y apache2 \
    libapache2-mod-wsgi \
    build-essential \
    python \
    python-dev\
    python-pip \
    vim \
 && apt-get clean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*

# Copy over and install the requirements
COPY ./app/requirements.txt /var/www/apache-flask/app/requirements.txt
RUN pip install -r /var/www/apache-flask/app/requirements.txt

# Copy over the apache configuration file and enable the site
COPY ./apache-flask.conf /etc/apache2/sites-available/apache-flask.conf
RUN a2ensite apache-flask
RUN a2enmod headers

# Copy over the wsgi file
COPY ./apache-flask.wsgi /var/www/apache-flask/apache-flask.wsgi

COPY ./run.py /var/www/apache-flask/run.py
COPY ./app /var/www/apache-flask/app/

RUN a2dissite 000-default.conf
RUN a2ensite apache-flask.conf

EXPOSE 80

WORKDIR /var/www/apache-flask

# CMD ["/bin/bash"]
CMD  /usr/sbin/apache2ctl -D FOREGROUND
# The commands below get apache running but there are issues accessing it online
# The port is only available if you go to another port first
# ENTRYPOINT ["/sbin/init"]
# CMD ["/usr/sbin/apache2ctl"]

# Ends the cross build script
RUN [ "cross-build-end" ]
