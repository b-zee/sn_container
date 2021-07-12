FROM docker.io/library/alpine:3.13

ADD https://github.com/maidsafe/sn_cli/releases/download/v0.30.1/sn_cli-0.30.1-x86_64-unknown-linux-musl.tar.gz        /sn_tars/sn_cli.tar.gz
ADD https://github.com/maidsafe/safe_network/releases/download/v0.2.17/sn_node-0.2.17-x86_64-unknown-linux-musl.tar.gz /sn_tars/sn_node.tar.gz

RUN sh -c 'for i in /sn_tars/*; do tar --extract --gzip --directory=/usr/local/bin --file $i; done' && \
  rm -r /sn_tars

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
