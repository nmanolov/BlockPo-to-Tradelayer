FROM tradelayer-installed

COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 9332 9333 19332 19333 19444

ENV LITECOIN_VERSION=0.16.3
ENV LITECOIN_DATA=/home/litecoin/.litecoin

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
VOLUME ["/home/litecoin/.litecoin"]
CMD ["litecoind"]
