#! /bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:   $remote_fs $syslog
# Required-Stop:    $remote_fs $syslog
# Default-Start:    2 3 4 5
# Default-Stop:     0 1 6
# Short-Description:
### END INIT INFO

EXEC=
PIDFILE=
OPTS=

. /lib/lsb/init-functions

case "$1" in
    start)
        log_daemon_msg "Starting " ""

        if start-stop-daemon --start --quiet --oknodo --make-pidfile --background --pidfile $PIDFILE --exec $EXEC -- $OPTS; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    ;;

    stop)
        log_daemon_msg "Stopping" ""

        if start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
        ;;

    reload|force-reload)
        log_daemon_msg "Reloading" ""

        if start-stop-daemon --stop --signal 1 --quiet --oknodo --make-pidfile --background --pidfile $PIDFILE --exec $EXEC; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
        ;;

    restart)
        log_daemon_msg "Restarting" ""
        start-stop-daemon --stop --quiet --oknodo --retry 30 --pidfile $PIDFILE

        if start-stop-daemon --start --quiet --oknodo --make-pidfile --background --pidfile $PIDFILE --exec $EXEC -- $OPTS; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
        ;;

    try-restart)
        log_daemon_msg "Restarting" ""

        start-stop-daemon --stop --quiet --retry 30 --pidfile $PIDFILE
        RET="$?"

        case $RET in
            0)
                if start-stop-daemon --start --quiet --oknodo --make-pidfile --background --pidfile $PIDFILE --exec $EXEC -- $OPTS; then
                    log_end_msg 0
                else
                    log_end_msg 1
                fi
                ;;
            1)
                log_progress_msg "(not running)"
                log_end_msg 0
                ;;
            *)
                log_progress_msg "(failed to stop)"
                log_end_msg 1
                ;;
        esac
        ;;

    status)
        status_of_proc -p $PIDFILE $EXEC && exit 0 || exit $?
        ;;

    *)
        log_action_msg "Usage: $0 {start|stop|reload|force-reload|restart|try-restart|status}"
        exit 1
esac

exit 0
