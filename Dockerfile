FROM python:3.9.16-buster
ARG SSH_PASS=password
ARG SSH_USER=user

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		postgresql-client sudo

RUN apt-get -y install --fix-missing openssh-server
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

#Add user
RUN useradd -m -s /bin/bash -p $(openssl passwd -1 $SSH_PASS) $SSH_USER
RUN usermod -g $SSH_USER $SSH_USER
RUN usermod -aG sudo $SSH_USER
RUN chown -R $SSH_USER.$SSH_USER /usr/src/app
RUN echo "cd /usr/src/app">>/home/$SSH_USER/.bashrc

RUN pip install django pillow djangorestframework django-cors-headers django-filter mysqlclient

RUN django-admin startproject mysite

RUN chown -R $SSH_USER.$SSH_USER /usr/src/app

WORKDIR /usr/src/app/mysite

ENTRYPOINT service ssh start && python manage.py runserver 0.0.0.0:8000