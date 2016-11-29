#!/bin/sh
# Tail syslog, trapping SIGTERM to trigger a clean container shutdown

tail -F /var/log/messages &
pid="$!"

trap "
	trap '' TERM;
	logger 'trapped SIGTERM, shutting down';
	openrc shutdown;
	kill '${pid}';
	wait '${pid}';
	exit
	" TERM

wait "${pid}"
