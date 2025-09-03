# Samtools base (pick a tag you need, e.g. 1.21 or latest)
FROM staphb/samtools:1.21

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Python 2 (works across Ubuntu 16.04→22.04 bases) + pip (2.7 bootstrap)
RUN set -eux; \
    # If the base is ancient Xenial, switch to old-releases mirrors
    . /etc/os-release || true; \
    if [ "${VERSION_CODENAME:-}" = "xenial" ] || [ "${VERSION_ID:-}" = "16.04" ]; then \
      sed -ri 's/archive.ubuntu.com|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list; \
    fi; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl; \
    # Prefer 'python2' if available (20.04+), else fall back to 'python2.7'
    if apt-cache show python2 >/dev/null 2>&1; then \
      apt-get install -y --no-install-recommends python2; \
      ln -sf /usr/bin/python2 /usr/bin/python; \
    else \
      apt-get install -y --no-install-recommends python2.7 python2.7-minimal; \
      ln -sf /usr/bin/python2.7 /usr/bin/python; \
    fi; \
    # Install last pip that supports Python 2.7
    curl -fsSL https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py; \
    python /tmp/get-pip.py; \
    pip --version; \
    # Cleanup
    apt-get purge -y curl; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/* /root/.cache /tmp/get-pip.py

ARG APP_HOME=/opt/modtect
WORKDIR ${APP_HOME}

COPY ModTect_1_7_5_1.py ${APP_HOME}/
COPY lib/               ${APP_HOME}/lib/
COPY sample/            ${APP_HOME}/sample/

ENV PYTHONPATH=${APP_HOME}/lib:$PYTHONPATH

# Quick runtime check
CMD ["bash", "-lc", "python --version && pip --version && samtools --version"]
