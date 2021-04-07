FROM docker.io/library/alpine:3.13

ADD https://sn-api.s3.amazonaws.com/sn_authd-0.4.0-x86_64-unknown-linux-musl.tar.gz                               /sn_tars/sn_authd.tar.gz
ADD https://github.com/maidsafe/sn_api/releases/download/v0.22.0/sn_cli-0.22.0-x86_64-unknown-linux-musl.tar.gz   /sn_tars/sn_cli.tar.gz
ADD https://github.com/maidsafe/sn_node/releases/download/v0.34.1/sn_node-0.34.1-x86_64-unknown-linux-musl.tar.gz /sn_tars/sn_node.tar.gz

RUN sh -c 'for i in /sn_tars/*; do tar --extract --gzip --directory=/usr/local/bin --file $i; done' && \
  rm -r /sn_tars

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]
