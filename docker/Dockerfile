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
    curl file xfonts-75dpi xfonts-base unzip build-essential fontconfig libfontconfig1 libpng16-16 \
    libldap2-dev libssl-dev poppler-utils ttf-dejavu cabextract libfreetype6 python3-magic git libffi-dev libc6 \
    libstdc++6 zlib1g libpoppler-cpp-dev pkg-config librdkafka-dev python3-cairocffi libpq-dev \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH

# wkhtmltopdf
RUN if [ "$TARGETARCH" = "arm64" ]; then \
    curl -sL -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_arm64.deb \
    && echo '134f986d2094491c37b9b53e9433ef2c393a298a /tmp/wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
    && rm -rf /tmp/wkhtmltox.deb; \
    else \
    curl -sL -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb \
    && echo '4a974456d6271908c46aa38fc177f99d6cd3b39a /tmp/wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
    && rm -rf /tmp/wkhtmltox.deb; \
fi

# lessc
ENV PATH="${PATH}:/opt/node/bin"
RUN if [ "$TARGETARCH" = "arm64" ]; then \
    curl -sL -o /tmp/node.tar.xz https://nodejs.org/dist/v18.20.3/node-v18.20.3-linux-arm64.tar.xz \
    && echo '3c497c19ddbf75bab7fecb36ddf1738622f0ba244aa1e0aebc70e46daf1a0794 /tmp/node.tar.xz' | sha256sum -c - \
    && tar -xf /tmp/node.tar.xz \
    && mv node-v18.20.3-linux-arm64 /opt/node \
    && rm -rf /tmp/node.tar.xz; \
    else \
    curl -sL -o /tmp/node.tar.xz https://nodejs.org/dist/v18.20.3/node-v18.20.3-linux-x64.tar.xz \
    && echo 'ffd6147c263b81016742dc1e72dc68885a3ca9b441d9744f9b76cad362d0cc5f /tmp/node.tar.xz' | sha256sum -c - \
    && tar -xf /tmp/node.tar.xz \
    && mv node-v18.20.3-linux-x64 /opt/node \
    && rm -rf /tmp/node.tar.xz; \
fi
RUN npm install -g less@4.2.0

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
    && make -j$(nproc) \
    && make install \
    && ln -s /usr/local/bin/gs /usr/local/bin/ghostscript \
    && rm -rf /tmp/${GHOSTSCRIPT_FILE_NAME} /tmp/${GHOSTSCRIPT_BASE_NAME}

# odoo directories
RUN useradd -s /usr/sbin/nologin --create-home --password odoo odoo \
  && mkdir /home/odoo/.local \
  && chown odoo:odoo /home/odoo/.local \
  && mkdir --parents /opt/odoo/tests \
  && chown --recursive odoo:odoo /opt/odoo

# msfonts
COPY docker/msfonts.sh /tmp/msfonts.sh
RUN chmod +x /tmp/msfonts.sh; sync; /tmp/msfonts.sh; rm -rf /tmp/msfonts.sh

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
