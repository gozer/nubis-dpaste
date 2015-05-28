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
        'NAME': nubis.DB_NAME,
        'USER': nubis.DB_USERNAME,
        'PASSWORD': nubis.DB_PASSWORD,
        'HOST': nubis.DB_SERVER,
    }
}

SECRET_KEY = nubis.APP_SECRET_KEY

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
