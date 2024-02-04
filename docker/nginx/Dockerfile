FROM nginx:latest

RUN apt-get update && \
    apt-get install -y curl git iputils-ping procps

ARG uname=nginx
ARG ugroup=nginx
ARG uid=$uid
ARG gid=$gid
RUN echo $uid $uname $gid $ugroup && \
    if [ $uid -ne 0 ]; then usermod --uid $uid $uname && groupmod --gid $gid $ugroup; fi
