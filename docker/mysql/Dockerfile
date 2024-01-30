FROM mariadb:11.1

RUN apt-get update && \
    apt-get install -y curl git iputils-ping procps

ARG uname=mysql
ARG ugroup=mysql
ARG uid=$uid
ARG gid=$gid
RUN echo $uid $uname $gid $ugroup && \
    usermod --uid $uid $uname && groupmod --gid $gid $ugroup
