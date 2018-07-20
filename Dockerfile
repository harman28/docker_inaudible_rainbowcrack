FROM ubuntu:bionic

RUN apt-get update && \
    apt-get install -y git ffmpeg mp4v2-utils

WORKDIR /root
VOLUME /data
RUN git clone https://github.com/inAudible-NG/tables.git
ADD . /root
CMD ["./decrypt-audiobooks.sh"]
