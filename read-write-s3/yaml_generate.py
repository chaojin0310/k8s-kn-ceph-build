from yaml import load, dump
from yaml import Loader, Dumper
import os

AWS_HOST = os.getenv('AWS_HOST')
AWS_PORT = os.getenv('AWS_PORT')
BUCKET_NAME = os.getenv('BUCKET_NAME')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')

with open('service.yaml', 'r') as f:
    data = load(f, Loader=Loader)
    container_list = data['spec']['template']['spec']['containers']

    for container in container_list:
        env_list = container['env']
        for env in env_list:
            if env['name'] == 'AWS_HOST':
                env['value'] = AWS_HOST
            elif env['name'] == 'AWS_PORT':
                env['value'] = AWS_PORT
            elif env['name'] == 'BUCKET_NAME':
                env['value'] = BUCKET_NAME
            elif env['name'] == 'AWS_ACCESS_KEY_ID':
                env['value'] = AWS_ACCESS_KEY_ID
            elif env['name'] == 'AWS_SECRET_ACCESS_KEY':
                env['value'] = AWS_SECRET_ACCESS_KEY

with open('service.yaml', 'w') as ff:
    dump(data, ff)