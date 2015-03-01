from dpaste.settings import *
import os

import imp
nubis = imp.load_source('nubis', '/etc/nubis-config/dpaste.sh')

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
    #('Your Name', 'name@example.com'),
)
MANAGERS = ADMINS

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': nubis.db_name,
        'USER': nubis.db_username,
        'PASSWORD': nubis.db_password,
        'HOST': nubis.app_db_server,
    }
}

SECRET_KEY = nubis.app_secret_key

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
