FROM rocker/r-ver:4.5.1

ENV AIR_VERSION=0.7.1

# install flir from r-universe precompiled binary, everything else from p3m
RUN apt-get update && apt-get install -qq -y curl libgit2-dev \
&& install2.r -e \
  -r https://etiennebacher.r-universe.dev/bin/linux/noble-x86_64/4.5 \
  -r https://p3m.dev/cran/__linux__/noble/latest \
  pak docopt roxygen2 cli fs flir \
&& curl -LsSf "https://github.com/posit-dev/air/releases/download/${AIR_VERSION}/air-installer.sh" | sh \
&& cp /root/.local/bin/air /usr/bin/air \
&& chmod +x /usr/bin/air \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/

WORKDIR /precommit
COPY flir flir
COPY style.sh style
COPY lint.R lint

RUN chmod +x lint style

ENTRYPOINT []
