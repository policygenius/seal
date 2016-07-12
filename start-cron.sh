#!/bin/sh
whenever -w
cron
tail -f /var/log/whenever.log
