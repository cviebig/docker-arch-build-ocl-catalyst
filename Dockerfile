FROM cviebig/arch-build-ocl

# catalyst-utils 15.5.-1 requires xorg-server<1.17.0
# which is available in a separate repository:
# https://wiki.archlinux.org/index.php/AMD_Catalyst#Xorg_repositories
# RUN echo "Server = http://catalyst.wirephire.com/repo/xorg116/\$arch" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf
# RUN echo "Server = http://mirror.rts-informatique.fr/archlinux-catalyst/repo/xorg116/\$arch" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf
# RUN echo "Server = http://mirror.hactar.bz/Vi0L0/xorg116/\$arch" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf
# RUN echo "[xorg116]" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf
# RUN pacman-key --keyserver pgp.mit.edu --recv-keys 0xabed422d653c3094
# RUN pacman-key --lsign-key 0xabed422d653c3094

RUN pacman -S --noprogressbar --noconfirm wget && \
    echo "Server = http://catalyst.wirephire.com/repo/xorg116/\$arch" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf && \
    echo "[xorg116]" | cat - /etc/pacman.conf > temp && mv temp /etc/pacman.conf && \
    pacman-key --keyserver pgp.mit.edu --recv-keys 0xabed422d653c3094 && \
    pacman-key --lsign-key 0xabed422d653c3094 && \
    pacman -Sy && \
    pacman -S --noconfirm xorg-server && \
    mkdir -v -p /var/abs/local && \
    cd /var/abs/local && \
    git clone https://aur.archlinux.org/catalyst-utils.git && \
    useradd -ms /bin/bash build || true && \
    chown -R build:build /var/abs/local && \
    chmod -R 744 /var/abs/local && \
    su -c "cd /var/abs/local/catalyst-utils && makepkg" - build && \
    pacman -Rcs --noconfirm clinfo && \
    yes | pacman -U /var/abs/local/catalyst-utils/catalyst-utils-*-x86_64.pkg.tar.xz \
                    /var/abs/local/catalyst-utils/opencl-catalyst-*-x86_64.pkg.tar.xz \
                    /var/abs/local/catalyst-utils/catalyst-libgl-*-x86_64.pkg.tar.xz && \
    rm -rf /var/abs/local/* && \
    pacman -Scc --noconfirm
