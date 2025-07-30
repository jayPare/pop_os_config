#!/bin/bash

echo "🖥️ Updating Gnome Terminal..."
echo "🛠️ Installing build dependencies..."

sudo apt update
sudo apt install -y \
    build-essential gettext liblz4-dev\
    libgtk-4-dev libvte-2.91-dev libglib2.0-dev \
    libpcre2-dev libxml2-utils yelp-tools \
    itstool gobject-introspection libgirepository1.0-dev \
    libdconf-dev pkg-config git \
    python3 python3-pip ninja-build \
    libgtk-4-dev libgtk-4-0 libgtk-4-examples \
    libglib2.0-dev libpango1.0-dev libcairo2-dev \
    libgdk-pixbuf-2.0-dev libepoxy-dev libx11-dev libxext-dev \
    libxrandr-dev libxrender-dev libxi-dev libxfixes-dev \
    libxcursor-dev libxdamage-dev libxcomposite-dev \
    libwayland-dev wayland-protocols libxkbcommon-dev \
    curl tar xz-utils libdrm-dev \
    apt-get install libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly gstreamer1.0-libav \
    gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa \
    gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio libsystemd-dev libadwaita-1-dev \
    libcurl4-openssl-dev autoconf libtool libzstd-dev gperf \
    flex bison libwayland-dev graphviz doxygen xsltproc \
    xmlto

pkg-config --cflags --libs gstreamer-1.0

# 🧪 Step 2: Download GTK 4.14.0 source
echo "📦 Downloading GTK 4.14.0 source..."
mkdir -p ~/src && cd ~/src
curl -O https://download.gnome.org/sources/gtk/4.14/gtk-4.14.0.tar.xz
tar -xf gtk-4.14.0.tar.xz
cd gtk-4.14.0

# 🏗️ Step 3: Build and install to user prefix
echo "🔨 Building GTK 4.14.0..."
# Workaround
find . -name meson.build -exec sed -i.bak 's/is_default: *true/is_default: not meson.is_subproject()/' {} \;
meson setup build --prefix=$HOME/.local
ninja -C builddir install
#ninja -C build
#ninja -C build install

# 🛠 Install Meson with pip (user local install)
pip3 install --user meson

# 🧭 Add GTK4 and Meson's local bin to PATH
echo 'export PKG_CONFIG_PATH="$HOME/.local/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="$HOME/.local/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# get Yaml
wget https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz
tar -xf 0.2.5.tar.gz
cd libyaml-0.2.5
./bootstrap
./configure --prefix=$HOME/.local
make
make install

git clone https://gitlab.gnome.org/GNOME/glib.git
cd glib
meson setup _build  --prefix=$HOME/.local
ninja -C _build
sudo -E ninja -C _build install

git clone https://gitlab.freedesktop.org/fontconfig/fontconfig.git
cd fontconfig
meson setup _build
ninja -C _build
sudo ninja -C _build install

git clone https://gitlab.freedesktop.org/wayland/wayland.git
cd wayland
git checkout 1.23.0
meson setup build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install

git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git
cd wayland-protocols
git checkout 1.44  # or 1.45 for the latest
meson setup build --prefix=/usr --buildtype=release
ninja -C build
sudo ninja -C build install

git clone https://gitlab.gnome.org/GNOME/libadwaita.git
cd libadwaita
meson setup _build  --prefix=$HOME/.local
ninja -C _build
sudo ninja -C _build install

echo "📦 Cloning GNOME Terminal source..."
git clone https://gitlab.gnome.org/GNOME/gnome-terminal.git ~/gnome-terminal-source
cd ~/gnome-terminal-source

echo "🔧 Creating build directory..."
meson setup build

echo "🚀 Compiling..."
ninja -C build

echo "🧩 Installing..."
sudo ninja -C build install

echo "✅ GNOME Terminal installed! You can run it with: gnome-terminal"
