FROM ubuntu:22.04

# variables & locales
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq \
    && apt-get upgrade -y\
    && apt-get install -y locales -qq \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales \
    && dpkg-reconfigure locales \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# dependencies for odoo or python packages
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends libjpeg-dev libsasl2-dev libxslt-dev libxml2-dev ca-certificates tzdata \
    curl file xfonts-75dpi xfonts-base unzip build-essential fontconfig libfontconfig1 libpng16-16 \
    libldap2-dev libssl-dev poppler-utils fonts-dejavu cabextract libfreetype6 git libffi-dev libc6 \
    libstdc++6 libpoppler-cpp-dev pkg-config librdkafka-dev libpq-dev \
    libbz2-dev libreadline-dev libsqlite3-dev liblzma-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETARCH

# wkhtmltopdf
RUN if [ "$TARGETARCH" = "arm64" ]; then \
    curl -sL -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_arm64.deb \
    && echo '0edcc573e8bbd7ba12885671e75cee8efe3ae11d /tmp/wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends /tmp/wkhtmltox.deb \
    && rm -rf /tmp/wkhtmltox.deb; \
    else \
    curl -sL -o /tmp/wkhtmltox.deb https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    && echo '800eb1c699d07238fee77bf9df1556964f00ffcf /tmp/wkhtmltox.deb' | sha1sum -c - \
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
COPY docker/0001-pdfwrite-undo-commit-4dcfae36bb4dcbc4ef3b5e5afc98bcd.patch /tmp/0001-pdfwrite-undo-commit-4dcfae36bb4dcbc4ef3b5e5afc98bcd.patch
RUN GHOSTSCRIPT_VERSION=10031 \
    && GHOSTSCRIPT_FILE_NAME=ghostscript-10.03.1.tar.gz \
    && GHOSTSCRIPT_BASE_NAME=$(basename ${GHOSTSCRIPT_FILE_NAME} .tar.gz) \
    && curl -sL -o /tmp/${GHOSTSCRIPT_FILE_NAME} https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${GHOSTSCRIPT_VERSION}/${GHOSTSCRIPT_FILE_NAME} \
    && tar -xzf /tmp/${GHOSTSCRIPT_FILE_NAME} -C /tmp \
    && cd /tmp/${GHOSTSCRIPT_BASE_NAME}/ \
    && patch -p1 < /tmp/0001-pdfwrite-undo-commit-4dcfae36bb4dcbc4ef3b5e5afc98bcd.patch \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && ln -s /usr/local/bin/gs /usr/local/bin/ghostscript \
    && mkdir /etc/odoo \
    && sed -e 's^srgb.icc^/etc/odoo/default_rgb.icc^' \
           -e 's^/OutputConditionIdentifier (sRGB)^/OutputConditionIdentifier (RGB)^' \
           lib/PDFA_def.ps > /etc/odoo/PDFA_def.ps \
    && cp iccprofiles/default_rgb.icc /etc/odoo/default_rgb.icc \
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
ENV PYENV_ROOT="/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"
COPY .python-version .
RUN PYTHON_VERSION="$(cat .python-version)" \
    && git clone --depth 1 -b v2.4.1 https://github.com/pyenv/pyenv.git "${PYENV_ROOT}" \
    && pyenv install --verbose ${PYTHON_VERSION} \
    && pyenv global ${PYTHON_VERSION} \
    && rm .python-version

# Poetry
RUN pip install --no-cache-dir poetry==1.8.3

USER odoo
WORKDIR /opt/odoo

# Dependencies
ENV PATH="/opt/odoo/.venv/bin:${PATH}"
COPY pyproject.toml .
COPY poetry.lock .
RUN poetry config virtualenvs.prefer-active-python true && \
    poetry config virtualenvs.in-project true && \
    poetry install --no-root --no-interaction --no-cache

COPY --chown=odoo:odoo . .

EXPOSE 8069 8072
VOLUME ["/home/odoo/.local"]
