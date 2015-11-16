FROM cviebig/arch-build-ocl

RUN pacman -S --noprogressbar --noconfirm opencl-headers java-environment unzip

RUN mkdir -v -p /var/abs/local
RUN cd /var/abs/local && \
    curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/amdapp-sdk.tar.gz && \
    curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/amdapp-aparapi.tar.gz && \
    curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/catalyst.tar.gz && \
    curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/catalyst-utils.tar.gz && \
    curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/clinfo.tar.gz && \
    tar -xzvf amdapp-sdk.tar.gz && \
    tar -xzvf amdapp-aparapi.tar.gz && \
    tar -xzvf catalyst.tar.gz && \
    tar -xzvf catalyst-utils.tar.gz && \
    tar -xzvf clinfo.tar.gz

RUN useradd -ms /bin/bash buildbot
RUN chown -R buildbot:buildbot /var/abs/local
RUN chmod -R 744 /var/abs/local

# catalyst-utils 15.5.-1 requires xorg-server<1.17.0
# which is available in a separate repository:
# https://wiki.archlinux.org/index.php/AMD_Catalyst#Xorg_repositories
RUN echo "Server = http://catalyst.wirephire.com/repo/xorg116/\$arch" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf
#RUN echo "Server = http://mirror.rts-informatique.fr/archlinux-catalyst/repo/xorg116/\$arch" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf
#RUN echo "Server = http://mirror.hactar.bz/Vi0L0/xorg116/\$arch" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf
RUN echo "[xorg116]" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf

RUN pacman-key --keyserver pgp.mit.edu --recv-keys 0xabed422d653c3094
RUN pacman-key --lsign-key 0xabed422d653c3094

## Mirrors, if the primary server does not work or is too slow:
#Server = http://mirror.rts-informatique.fr/archlinux-catalyst/repo/xorg116/$arch
#Server = http://mirror.hactar.bz/Vi0L0/xorg116/$arch

RUN su -c "cd /var/abs/local/catalyst-utils && makepkg" - buildbot
RUN pacman -Sy
RUN pacman -S --noconfirm xorg-server
# use yes instead of --noconfirm to to resolve conflict between
# catalyst-libgl and mesa-libgl (libgl)
RUN yes | pacman -U /var/abs/local/catalyst-utils/catalyst-utils-*-x86_64.pkg.tar.xz \
                    /var/abs/local/catalyst-utils/opencl-catalyst-*-x86_64.pkg.tar.xz \
                    /var/abs/local/catalyst-utils/catalyst-libgl-*-x86_64.pkg.tar.xz

#RUN pacman -S --noconfirm git
#RUN su -c "cd /var/abs/local/clinfo && makepkg" - buildbot
#RUN pacman -U --noconfirm /var/abs/local/clinfo/clinfo-*-x86_64.pkg.tar.xz
