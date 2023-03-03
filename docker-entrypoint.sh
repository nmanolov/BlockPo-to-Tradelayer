#!/bin/sh

chown -R litecoin:litecoin /home/litecoin
exec runuser -u litecoin -- "$@"
