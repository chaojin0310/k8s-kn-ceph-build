# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.7-slim

# RUN export AWS_HOST=rook-ceph-rgw-my-store.rook-ceph.svc
# RUN export PORT=80
# RUN export BUCKET_NAME=ceph-bkt-03240bc3-d14e-45c7-8013-04744c5056ad
# RUN export AWS_ACCESS_KEY_ID=61C7ECHF1XRC2CUB3WPJ
# RUN export AWS_SECRET_ACCESS_KEY=mMt5dlIxwIX2jEdpEwNkQkhpd4PNd1IQADTMqTFY

# RUN mkdir ~/.aws
# RUN echo "[default]" >> ~/.aws/credentials
# RUN echo "aws_access_key_id = ${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
# RUN echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials

# RUN echo "Hello xxy!" > /tmp/rookObj

RUN pip install boto3
RUN pip install flask

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

# Install production dependencies.
RUN pip install Flask gunicorn

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
