FROM eclipse-temurin:21-jre
WORKDIR /server

RUN apt-get update && \
    apt-get install -y curl unzip git vim build-essential yq cron && \
    curl https://rclone.org/install.sh | bash && \
    git clone https://github.com/Tiiffi/mcrcon.git /tmp/mcrcon && \
    cd /tmp/mcrcon && make && \
    cp /tmp/mcrcon/mcrcon /usr/local/bin/mcrcon && \
    rm -rf /tmp/mcrcon

COPY scripts/start.sh /start.sh
COPY scripts/backup.sh /backup.sh
RUN chmod +x /start.sh /backup.sh

EXPOSE 25565 25575
VOLUME ["/server"]
CMD ["/start.sh"]
