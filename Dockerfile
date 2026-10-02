# Lab box: a small "Linux server" every friend can SSH into.
# Plain Docker is enough for sessions 1-5 (no systemd inside).
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8

# Ubuntu's docker image strips man pages; re-enable them.
RUN rm -f /etc/dpkg/dpkg.cfg.d/excludes \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-server sudo cron curl wget ca-certificates \
      iputils-ping iproute2 dnsutils netcat-openbsd \
      procps psmisc lsof htop tree nano vim-tiny less \
      man-db manpages file git python3 openssl gawk bash-completion \
 && rm -rf /var/lib/apt/lists/*

# The 'ubuntu' user (uid 1000) ships with the image; replace it with 'student'.
RUN userdel -r ubuntu 2>/dev/null || true \
 && useradd -m -s /bin/bash -u 1000 student \
 && echo 'student ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/student \
 && chmod 440 /etc/sudoers.d/student \
 && mkdir -p /run/sshd

COPY lab/sshd-lab.conf /etc/ssh/sshd_config.d/00-lab.conf
COPY lab/ /opt/lab/
RUN chmod +x /opt/lab/*.sh /opt/lab/lab-check /opt/lab/check/*.sh \
 && ln -s /opt/lab/lab-check /usr/local/bin/lab-check \
 && cp /opt/lab/motd /etc/motd

EXPOSE 22
ENTRYPOINT ["/opt/lab/entrypoint.sh"]
