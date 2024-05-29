FROM ubuntu:22.04

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
    && apt-get install -y --no-install-recommends python3 python3-pip python3-dev libjpeg-dev libsasl2-dev libxslt-dev libxml2-dev ca-certificates tzdata \
    curl file xfonts-75dpi xfonts-base unzip build-essential fontconfig libfontconfig1 libpng16-16 \
    libldap2-dev libssl-dev poppler-utils fonts-dejavu cabextract libfreetype6 git libffi-dev libc6 \
    libstdc++6 lib32z1 libpoppler-cpp-dev pkg-config librdkafka-dev node-less libpq-dev \
    libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

# wkhtmltopdf
RUN curl -sL -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && echo '800eb1c699d07238fee77bf9df1556964f00ffcf /tmp/wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
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
RUN useradd -s /usr/sbin/nologin --create-home --password odoo odoo \
  && mkdir /home/odoo/.local \
  && chown odoo:odoo /home/odoo/.local \
  && mkdir --parents /opt/odoo/tests \
  && chown --recursive odoo:odoo /opt/odoo

# msfonts
COPY docker/msfonts.sh /tmp/msfonts.sh
RUN chmod +x /tmp/msfonts.sh; sync; /tmp/msfonts.sh; rm -rf /tmp/msfonts.sh

# Python
ARG PYTHON_VERSION=3.8.10
ENV PYENV_ROOT="$HOME/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
RUN git clone --depth 1 -b v2.4.1 https://github.com/pyenv/pyenv.git "${PYENV_ROOT}" \
    && pyenv install ${PYTHON_VERSION} \
    && pyenv global ${PYTHON_VERSION}

# pip dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir setuptools --upgrade \
    && pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir python-magic==0.4.27 cairocffi==0.9.0 -r /tmp/requirements.txt \
    && rm -rf /tmp/requirements.txt

RUN apt-get purge -y build-essential

WORKDIR /opt/odoo
COPY --chown=odoo:odoo . .

EXPOSE 8069 8072
USER odoo
VOLUME ["/home/odoo/.local"]
