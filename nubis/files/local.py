# After 2.8
try:
  from dpaste.settings.base import *
# 2.8 and before
except:
  from dpaste.settings import *

import imp
nubis = imp.load_source('nubis', '/etc/nubis-config/nubis-dpaste.sh')

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
    #('Your Name', 'name@example.com'),
)
MANAGERS = ADMINS

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': nubis.Database_Name,
        'USER': nubis.Database_User,
        'PASSWORD': nubis.Database_Password,
        'HOST': nubis.Database_Server,
    }
}

SECRET_KEY = nubis.APP_SECRET_KEY

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
