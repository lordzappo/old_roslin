FROM python:2.7.13-alpine

LABEL maintainer="Jaeyoung Chun (chunj@mskcc.org)" \
      version.image="1.0.0" \
      version.removevariants="0.1.1" \
      version.alpine="3.4.6" \
      source.removevariants="https://github.com/mskcc/remove_variants/releases/tag/0.1.1"

ENV REMOVEVARIANTS_VERSION 0.1.1

RUN apk add --update \
      # for wget
            && apk add ca-certificates openssl \
      # for compilation (numpy, ...)
            && apk add build-base musl-dev \
      # download, unzip, install
            && cd /tmp && wget https://github.com/mskcc/remove_variants/archive/${REMOVEVARIANTS_VERSION}.zip \
            && unzip ${REMOVEVARIANTS_VERSION}.zip \
            && cd /tmp/remove_variants-${REMOVEVARIANTS_VERSION} \
            && python setup.py install \
      # copy to /usr/bin
            && cp /tmp/remove_variants-${REMOVEVARIANTS_VERSION}/remove_variants.py /usr/bin/ \
      # clean up
            && rm -rf /var/cache/apk/* /tmp/*

# disable per-user site-packages before run
ENV PYTHONNOUSERSITE set

ENTRYPOINT ["python", "/usr/bin/remove_variants.py"]
CMD ["--help"]
