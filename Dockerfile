FROM alpine:3.11

MAINTAINER Alexei Ledenev <alexei@codefresh.io>

# default Docker API version: override to work with older docker server
ENV DOCKER_API_VERSION 1.40
# default docker client version
ENV DOCKER_VERSION 19.03.11
# default aws version
ENV AWSCLI_VERSION 1.18.80

# add some packages
RUN apk --no-cache add curl bash openssl openssh-client python python-dev py-pip build-base \
    && pip install awscli==$AWSCLI_VERSION --upgrade --user \
    && apk --purge -v del py-pip \
    && rm -rf /var/cache/apk/*

# install docker client
RUN curl -o "/tmp/docker-${DOCKER_VERSION}.tgz" -LS "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" && \
    curl -o "/tmp/docker-${DOCKER_VERSION}.tgz.sha256" -LS "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz.sha256" && \
    cd /tmp && sha256sum -c "docker-${DOCKER_VERSION}.tgz.sha256" && \
    tar -xvzf "/tmp/docker-${DOCKER_VERSION}.tgz" -C /tmp/ && \
    chmod u+x /tmp/docker/docker && mv /tmp/docker/docker /usr/bin/ && \
    rm -rf /tmp/*

# install rdocker script
COPY rdocker.sh /usr/local/bin/rdocker
RUN chmod +x /usr/local/bin/rdocker

CMD ["rdocker"]

# labels for https://microbadger.com/ service
ARG GH_SHA
LABEL org.label-schema.vcs-ref=$GH_SHA \
      org.label-schema.vcs-url="https://github.com/codefresh-io/remote-docker"
