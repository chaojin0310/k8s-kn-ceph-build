import os
import sys
import re

from flask import Flask
import boto3
import logging
from botocore.exceptions import ClientError

app = Flask(__name__)

AWS_HOST = os.getenv('AWS_HOST')
AWS_PORT = os.getenv('AWS_PORT')
BUCKET_NAME = os.getenv('BUCKET_NAME')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY')

stop_list = ['\n']

def read(filename, split = " "):
    assert isinstance(filename, str)
    assert isinstance(split, str)
    return_list = []
    with open(filename, 'r') as f:
        tmpstr = f.readline()
        while(tmpstr):
            tmplist = re.split(split, tmpstr)
            for i in stop_list:
                try:
                    tmplist.remove(i)
                except:
                    pass
            return_list.append(tmplist)
            tmpstr = f.readline()
    return return_list


@app.route('/id/<id>')
def wc_map():
    s3_client = boto3.client(
        service_name='s3',
        endpoint_url='http://{}:{}'.format(AWS_HOST, AWS_PORT),
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    )

    # download from s3

    input_path = "/input0"
    res = read(input_path)

    output_path = "/output0"
    output_name = "intermediate_data_0"

    token_list = [',', '.', '!']

    with open(output_path, 'w+') as f:
        for line in res:
            for i in range(len(line)):
                for token in token_list:
                    cnt = line[i].count(token)
                    if cnt > 0:
                        f.write(token+" "+str(cnt)+"\n")
                line[i] = line[i].strip(",.!\n")
                f.write(line[i]+" 1\n")

    try:
        s3_client.upload_file(output_path, BUCKET_NAME, "intermediate_data_0")
    except ClientError as e:
        logging.error(e)
        return "Uploading failed\n"
    
    return "Intermediate data uploaded\n"


if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 80)))
