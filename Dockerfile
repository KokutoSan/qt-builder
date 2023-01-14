FROM centos:7.9.2009

# Build arguments
ARG USERNAME=qt
ARG USER_UID=1000
ARG USER_GID=1000

# Configure Yum repository for CentOS 
COPY etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo 

# Downgrade nss-softokn 
RUN yum downgrade -y nss-softokn-freebl.x86_64 nss-softokn.x86_64 nss.x86_64 nss-sysinit.x86_64 nss-tools.x86_64

# Install dependencies
RUN yum install -y bluez-libs.x86_64 dejavu-fonts-common.noarch avahi-libs.x86_64 fontpackages-filesystem.noarch \
                   fontconfig.x86_64 cups-libs.x86_64 glx-utils.x86_64 dejavu-sans-fonts.noarch graphite2.x86_64 \
                   harfbuzz.x86_64 libSM.x86_64 libICE.x86_64 libXau.x86_64 libXdamage.x86_64 libXfixes.x86_64 \
                   libXext.x86_64 libXxf86vm.x86_64 libXi.x86_64 libglvnd-egl.x86_64 libglvnd.x86_64 libglvnd-glx.x86_64 \
                   libjpeg-turbo.x86_64 libpciaccess.x86_64 libpng.x86_64 libtool-ltdl.x86_64 libwayland-client.x86_64 \
                   libwayland-server.x86_64 libxcb.x86_64 libxshmfence.x86_64 mariadb-libs.x86_64 hwdata.x86_64 \
                   pcre2-utf16.x86_64 glibc.i686 xcb-util.x86_64 xcb-util-image.x86_64 xcb-util-keysyms.x86_64 \
                   xcb-util-renderutil.x86_64 unixODBC.x86_64 xcb-util-wm.x86_64 libicu.x86_64 kbd.x86_64 which \
                   libXinerama.x86_64 libxkbcommon-x11.x86_64 libXrender.x86_64 python3.x86_64 python3-libs.x86_64 \
                   python3-pip.noarch python3-setuptools.noarch emacs-filesystem.noarch libdrm.x86_64 \
                   libdrm-devel.x86_64 mesa-libGL mesa-libGL-devel mesa-dri-drivers.x86_64 file zlib-devel.x86_64 \
                   zlib.x86_64 libssh2-devel alsa-lib git bzip2.x86_64 make

# Install CentOS SCL
RUN yum install -y centos-release-scl

# Install devtoolset-8
RUN yum install -y devtoolset-8

# Install Python 3.8
RUN yum install -y rh-python38.x86_64 rh-python38-python-pip.noarch

# Install A Qt Install
RUN source /opt/rh/rh-python38/enable && pip3 install aqtinstall

# Install Qt5.12.5
RUN source /opt/rh/rh-python38/enable && \
    mkdir /opt/Qt5.12.5 && \
    aqt install-qt linux desktop 5.12.5 gcc_64 -O /opt/Qt5.12.5

# Copy CMake3.17.5 RPMs
COPY RPMS/ /root/RPMS/

# Install CMake3
RUN cd /root/RPMS && yum install -y cmake3-3.17.5-1.el7.x86_64.rpm cmake3-data-3.17.5-1.el7.noarch.rpm \
                                    cmake3-doc-3.17.5-1.el7.noarch.rpm libuv-1.30.1-1.el7.x86_64.rpm \
                                    libzstd-1.5.2-1.el7.x86_64.rpm rhash-1.3.4-2.el7.x86_64.rpm
RUN rm -rf /root/RPMS && \
    ln -s /usr/bin/cmake3 /usr/bin/cmake 

# Configure D-Bus to avoid an issue when exporting X11
RUN dbus-uuidgen --ensure

# Go to non-root user
RUN groupadd --gid $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME 

USER $USERNAME
WORKDIR /home/$USERNAME 

# Update bashrc
RUN echo "export PATH=$PATH:/opt/Qt5.12.5/5.12.5/gcc_64/bin" >> .bashrc && \
    echo "source /opt/rh/rh-python38/enable" >> .bashrc && \
    echo "source /opt/rh/devtoolset-8/enable" >> .bashrc

CMD ["/bin/bash"]
