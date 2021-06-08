FROM ubuntu:18.04

LABEL maintainer="Reinhard Pointner <rednoah@filebot.net>"


# Grab build dependencies
RUN apt-get update \
 && apt-get dist-upgrade --yes \
 && apt-get install --yes curl jq squashfs-tools \
 && rm -rvf /var/lib/apt/lists/*


# Grab the core snap
RUN curl --silent --location --output core.snap $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core' | jq '.download_url' -r) \
 && mkdir -p /snap/core \
 && unsquashfs -d /snap/core/current core.snap \
 && rm core.snap


# Grab the core18 snap
RUN curl --silent --location --output core18.snap $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core18' | jq '.download_url' -r) \
 && mkdir -p /snap/core18 \
 && unsquashfs -d /snap/core18/current core18.snap \
 && rm core18.snap


# Grab the gnome-3-34-1804-sdk snap
RUN curl --silent --location --output gnome.snap $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/gnome-3-34-1804-sdk' | jq '.download_url' -r) \
 && mkdir -p /snap/gnome-3-34-1804-sdk \
 && unsquashfs -d /snap/gnome-3-34-1804-sdk/current gnome.snap \
 && rm gnome.snap


# Grab the snapcraft snap from the candidate channel
RUN curl --silent --location --output snapcraft.snap $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/snapcraft?channel=candidate' | jq '.download_url' -r) \
 && mkdir -p /snap/snapcraft \
 && unsquashfs -d /snap/snapcraft/current snapcraft.snap \
 && rm snapcraft.snap


# Create a snapcraft runner
RUN mkdir -p /snap/bin \
 && echo "#!/bin/sh" > /snap/bin/snapcraft \
 && snap_version="$(awk '/^version:/{print $2}' /snap/snapcraft/current/meta/snap.yaml)" && echo "export SNAP_VERSION=\"$snap_version\"" >> /snap/bin/snapcraft \
 && echo 'exec "$SNAP/usr/bin/python3" "$SNAP/bin/snapcraft" "$@"' >> /snap/bin/snapcraft \
 && chmod +x /snap/bin/snapcraft


# Generate locale and install dependencies
RUN apt-get update \
 && apt-get dist-upgrade --yes \
 && apt-get install --yes snapd sudo locales \
 && locale-gen en_US.UTF-8 \
 && rm -rvf /var/lib/apt/lists/*


 # Pre-Install build dependencies
RUN apt-get update \
 && apt-get install --yes binutils binutils-common binutils-x86-64-linux-gnu cpp cpp-7 gcc gcc-7 gcc-7-base libasan4 libatomic1 libbinutils libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libgcc-7-dev libgomp1 libisl19 libitm1 liblsan0 libmpc3 libmpfr6 libmpx2 libquadmath0 libtsan0 libubsan0 linux-libc-dev make manpages manpages-dev \
 && rm -rvf /var/lib/apt/lists/*


 # Pre-Install application dependencies
RUN apt-get update \
 && apt-get install --yes mediainfo xdg-utils \
 && rm -rvf /var/lib/apt/lists/*


# Set the proper environment
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="/snap/bin:$PATH"
ENV SNAP="/snap/snapcraft/current"
ENV SNAP_NAME="snapcraft"
ENV SNAP_ARCH="amd64"


# Run snapcraft
WORKDIR /build

ENTRYPOINT ["/snap/bin/snapcraft"]
