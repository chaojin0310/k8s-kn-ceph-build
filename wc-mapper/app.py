import os
import re
import boto3
import logging
from flask import Flask
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
def wc_map(id):
    s3_client = boto3.client(
        service_name='s3',
        endpoint_url='http://{}:{}'.format(AWS_HOST, AWS_PORT),
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY
    )

    # download from s3
    input_path = "/app/input"+str(id)
    input_name = "input"+str(id)
    try:
        s3_client.download_file(BUCKET_NAME, input_name, input_path)
    except ClientError as e:
        logging.error(e)
        return "Failed to download input data\n"

    # word count mapping computation
    res = read(input_path)

    output_path = "/app/output"+str(id)
    output_name = "intermediate_data_"+str(id)
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

    # upload intermediate data
    try:
        s3_client.upload_file(output_path, BUCKET_NAME, output_name)
    except ClientError as e:
        logging.error(e)
        return "Failed to upload intermediate data\n"
    
    return "Intermediate data uploaded\n"


if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 80)))
