FROM rocker/r-ver:4.5.1

# Install rust separately as caching step
ENV RUST_VERSION=1.89.0
RUN apt-get update \
&& apt-get install -qq -y curl tar build-essential \
&& curl -O https://static.rust-lang.org/dist/rust-${RUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz \
&& tar -xzf rust-${RUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz \
&& cd rust-${RUST_VERSION}-x86_64-unknown-linux-gnu \
&& ./install.sh --prefix=/usr/local --disable-ldconfig \
&& cd .. \
&& rm -rf rust-${RUST_VERSION}-x86_64-unknown-linux-gnu* \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/

ENV AIR_VERSION=0.7.1

RUN apt-get update \
&& install2.r -e -r https://r-lib.github.io/p/pak/stable/source/linux-gnu/x86_64 pak \
&& install2.r -e -r https://p3m.dev/cran/__linux__/noble/latest docopt flir astgrepr roxygen2 fs cli \
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
