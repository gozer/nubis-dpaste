from dpaste.settings import *
import os

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
    #('Your Name', 'name@example.com'),
)
MANAGERS = ADMINS

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('PROVISION_db_name'),
        'USER': os.getenv('PROVISION_db_username'),
        'PASSWORD': os.getenv('PROVISION_db_password'),
        'HOST': os.getenv('PROVISION_app_db_server'),
    }
}

SECRET_KEY = os.getenv('PROVISION_app_secret_key')

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
