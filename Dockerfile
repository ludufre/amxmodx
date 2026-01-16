FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEPENDENCIES_FOLDER=dependencies
ENV DEPENDENCIES_ROOT=/root/dependencies
ENV CC=gcc-9
ENV CXX=g++-9

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        python3 \
        python3-pip \
        gcc-multilib \
        g++-multilib \
        libstdc++6 \
        lib32stdc++6 \
        libc6-dev \
        libc6-dev-i386 \
        linux-libc-dev \
        linux-libc-dev:i386 \
        lib32z1-dev \
        nasm \
        gcc-9 \
        gcc-9-multilib \
        g++-9 \
        g++-9-multilib \
        && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip setuptools wheel

WORKDIR /root

COPY <<'EOF' /root/build.sh
#!/bin/bash
set -e

PATH=$PATH:/root/.local/bin

if [ ! -d "/root/amxmodx" ]; then
    echo "ERRO: Monte o código: -v \$(pwd):/root/amxmodx"
    exit 1
fi

mkdir -p ${DEPENDENCIES_FOLDER}
cd ${DEPENDENCIES_FOLDER}
mkdir -p amxmodx
../amxmodx/support/checkout-deps.sh

echo "Compilador: ${CC} / ${CXX}"
${CC} --version
${CXX} --version

cd ../amxmodx
mkdir -p build
cd build

python3 ../configure.py \
    --enable-optimize \
    --metamod=${DEPENDENCIES_ROOT}/metamod-am \
    --hlsdk=${DEPENDENCIES_ROOT}/hlsdk \
    --mysql=${DEPENDENCIES_ROOT}/mysql-5.5

ambuild

echo "✅ Compilação concluída!"
echo "📦 Pacotes em: /root/amxmodx/build/packages/"
EOF

RUN chmod +x /root/build.sh

CMD ["/bin/bash", "/root/build.sh"]