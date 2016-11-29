FROM hongshunyang/gentoo-stage3-amd64
MAINTAINER Hongshun Yang <yanghongshun@gmail.com>
##TODO:GENTOO-SOURCE /USR/SRC/LINUX
##TODO:~amd64

#emerge --info

#CONFIGURE:/etc/make.conf
RUN echo 'ACCEPT_KEYWORDS="amd64"' >> /etc/portage/make.conf
RUN sed -i 's/USE=\".*"//g' /etc/portage/make.conf
RUN echo 'USE="-X -perl -python -test -debug -doc "' >> /etc/portage/make.conf

##CONFIGRUE:/etc/portage
## Application Containers should share data with host os(gentoo cloud image) for managing container cluster
RUN echo 'PORTAGE_RSYNC_EXTRA_OPTS="--exclude-from=/etc/portage/rsync_excludes"' >> /etc/portage/make.conf
COPY ./etc/portage/rsync_excludes /etc/portage/rsync_excludes
RUN mkdir -p /etc/portage/repos.conf
RUN cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf

## INSTALL:/usr/portage
ADD http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2 /
RUN bzcat /portage-latest.tar.bz2 | tar -xf - -C /usr
RUN mkdir -p /usr/portage/distfiles /usr/portage/metadata /usr/portage/packages
RUN rm /portage-latest.tar.bz2

##PYTHON_TARGET python3x
RUN PYTHON_TARGETS=$(emerge --info | sed -n 's/.*PYTHON_TARGETS="\([^"]*\)".*/\1/p') && \
    PYTHON_TARGET="${PYTHON_TARGETS##* }" && \
    echo "PYTHON_TARGETS=\"${PYTHON_TARGET}\"" >> /etc/portage/make.conf && \
    echo "PYTHON_SINGLE_TARGET=\"${PYTHON_TARGET}\"" >> /etc/portage/make.conf
RUN eselect python set $(eselect python show --python3)

RUN echo "FEATURES=\"${FEATURES} -ccache -sandbox -usersandbox noman noinfo nodoc\"" >> /etc/portage/make.conf
RUN echo "EMERGE_DEFAULT_OPTS=\"${EMERGE_DEFAULT_OPTS} -q --jobs 4\"" >> /etc/portage/make.conf


#DNS(worked)

#CONFIGURE:locales(LINGUAS)
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
RUN locale-gen
RUN echo 'LANG="en_US.UTF-8"' >> /etc/env.d/02locale
RUN env-update
RUN echo 'LINGUAS="en en_US"' >> /etc/portage/make.conf

#CONFIGURE:Networking
RUN echo 'rc_provide="loopback net"' >> /etc/rc.conf
RUN rc-update delete loopback boot
RUN rc-update delete netmount default
## Log boot process to /var/log/rc.log
RUN sed -i 's/^#\(rc_logger="YES"\)$/\1/' /etc/rc.conf

#CONFIGURE:Timezone(gentoo/stage3-amd64 UTC)
RUN emerge --config sys-libs/timezone-data
RUN emerge --newuse --deep --with-bdeps=y @system @world

#CONFIGURE:SYSLOG-NG
RUN emerge sys-process/vixie-cron app-admin/syslog-ng app-admin/logrotate
RUN rc-update add syslog-ng default
RUN rc-update add vixie-cron default
COPY tail-syslog-ng.sh /usr/bin/tail-syslog-ng
## Disable logging to tty12
RUN sed -i 's/^\([^#].*console_all.*\)/#\1/' /etc/syslog-ng/syslog-ng.conf
## Disable the system source (/proc/kmsg)
RUN sed -i 's/^\(.*\)system(); \(.*\)/\1\2/' /etc/syslog-ng/syslog-ng.conf
## Enable /dev/log
RUN sed -i 's|^\(.* internal();\)\(.*\)|\1 unix-stream("/dev/log");\2|' /etc/syslog-ng/syslog-ng.conf
CMD openrc default && exec tail-syslog-ng

#INSTALL:tools
RUN emerge eix \
&& eix-update \
&& eix-sync \
&& emerge \
app-admin/localepurge \
dev-vcs/git

##app-portage/gentoolkit \
##RUN eclean-dist && eclean-pkg
##CONFIGURE:layman(TODO:need python2)
##RUN emerge app-portage/layman
##RUN echo "source /var/lib/layman/make.conf" >> /etc/portage/make.conf

## CLEAN
COPY ./etc/locale.nopurge /etc/locale.nopurge
RUN localepurge 
RUN rm -rf /usr/portage/distfiles/*

RUN eselect news read new

## deepclean world

RUN perl-cleaner --all \
&& emerge --depclean

## as small as possible
## as simple as possible
## as fast as possible
