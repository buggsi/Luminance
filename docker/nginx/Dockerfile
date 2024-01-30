FROM nginx:latest

RUN apt-get update && \
    apt-get install -y curl git iputils-ping procps

ARG uname=nginx
ARG ugroup=nginx
ARG uid=$uid
ARG gid=$gid
RUN echo $uid $uname $gid $ugroup && \
    usermod --uid $uid $uname && groupmod --gid $gid $ugroup
