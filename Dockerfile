# ref: https://github.com/yukiyan/digdag-on-ecs
FROM java:8

MAINTAINER Naoki Ainoya <ainonic@gmail.com>

ENV DIGDAG_VERSION=0.9.12
ENV EMBULK_VERSION=0.8.23
ARG EMBULK_BUNDLE_DIR=embulk_bundle
ENV EMBULK_BUNDLE_DIR=$EMBULK_BUNDLE_DIR

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
      jruby && \
    curl -s -o /usr/local/bin/digdag --create-dirs -L "https://dl.digdag.io/digdag-${DIGDAG_VERSION}" && \
    chmod +x /usr/local/bin/digdag && \
    curl -s -o /usr/local/bin/embulk --create-dirs -L "https://dl.bintray.com/embulk/maven/embulk-${EMBULK_VERSION}.jar" && \
    chmod +x /usr/local/bin/embulk && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* && \
    adduser --shell /sbin/nologin --disabled-password --gecos "" digdag

USER digdag

WORKDIR /home/digdag

ONBUILD COPY $EMBULK_BUNDLE_DIR $EMBULK_BUNDLE_DIR
ONBUILD RUN cd $EMBULK_BUNDLE_DIR && embulk bundle clean && embulk bundle install
ONBUILD RUN  cd $EMBULK_BUNDLE_DIR 
ONBUILD COPY tasks tasks
ONBUILD COPY main.dig .

EXPOSE 65432

CMD ["java", "-jar", "/usr/local/bin/digdag", "scheduler", "-m"]