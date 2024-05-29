FROM ubuntu:18.04 AS python_kafka
USER root
RUN apt update && apt install -y git wget software-properties-common lsb-release gcc make python3 python3-pip python3-dev libsasl2-modules-gssapi-mit
RUN cd /tmp && git clone https://github.com/edenhill/librdkafka.git && \
    cd librdkafka && git checkout tags/v1.7.0 && \
    ./configure && make && make install

FROM ubuntu:20.04

# variables & locales
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq \
    && apt-get upgrade -y\
    && apt-get install -y locales -qq \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales \
    && dpkg-reconfigure locales \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# dependencies for odoo or python packages
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends python3 python3-pip python3-dev libjpeg-dev libsasl2-dev libxslt-dev libxml2-dev ca-certificates \
    curl file xfonts-75dpi xfonts-base unzip wget build-essential fontconfig libfontconfig1 libpng16-16 \
    libldap2-dev libssl-dev poppler-utils ttf-dejavu cabextract libfreetype6 python3-magic git libffi-dev libc6 \
    libstdc++6 zlib1g libpoppler-cpp-dev pkg-config python3-cairocffi node-less libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# wkhtmltopdf
RUN wget -O /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_arm64.deb \
    && dpkg -i /tmp/wkhtmltox.deb \
    && rm -rf /tmp/wkhtmltox.deb

# ghostscript
COPY docker/ghostscript_cmap_copyfix.diff /tmp/ghostscript_cmap_copyfix.diff
RUN GHOSTSCRIPT_VERSION=10020 \
    && GHOSTSCRIPT_FILE_NAME=ghostscript-10.02.0.tar.gz \
    && GHOSTSCRIPT_BASE_NAME=$(basename ${GHOSTSCRIPT_FILE_NAME} .tar.gz) \
    && curl -sL -o /tmp/${GHOSTSCRIPT_FILE_NAME} https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${GHOSTSCRIPT_VERSION}/${GHOSTSCRIPT_FILE_NAME} \
    && tar -xzf /tmp/${GHOSTSCRIPT_FILE_NAME} -C /tmp \
    && cd /tmp/${GHOSTSCRIPT_BASE_NAME}/ \
    && patch -p1 < /tmp/ghostscript_cmap_copyfix.diff \
    && ./configure \
    && make \
    && make install \
    && ln -s /usr/local/bin/gs /usr/local/bin/ghostscript \
    && rm -rf /tmp/${GHOSTSCRIPT_FILE_NAME} /tmp/${GHOSTSCRIPT_BASE_NAME}

    # odoo directories
RUN useradd -s /usr/bin/nologin --create-home --password odoo odoo \
  && mkdir /home/odoo/.local \
  && chown odoo:odoo /home/odoo/.local \
  && mkdir --parents /opt/odoo/tests \
  && chown --recursive odoo:odoo /opt/odoo

# msfonts
COPY docker/msfonts.sh /tmp/msfonts.sh
RUN chmod +x /tmp/msfonts.sh; sync; /tmp/msfonts.sh; rm -rf /tmp/msfonts.sh

COPY --from=python_kafka /usr/local/lib /usr/local/lib
COPY --from=python_kafka /usr/local/include /usr/local/include
COPY --from=python_kafka /usr/local/share/doc/librdkafka /usr/local/share/doc/librdkafka

# ldconfig
RUN ldconfig


# pip dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir setuptools --upgrade \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    && rm -rf /tmp/requirements.txt

RUN apt-get purge -y build-essential

WORKDIR /opt/odoo
COPY --chown=odoo:odoo . .

EXPOSE 8069 8072
USER odoo
VOLUME ["/home/odoo/.local"]