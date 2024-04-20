MAINTAINER roel@gloudemans.info

FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /

# Put files into place
COPY startup.sh /startup.sh
COPY install_rms.sh /install_rms.sh
RUN chmod 755 /startup.sh && chmod 755 /install_rms.sh && /install_rms.sh

ENTRYPOINT ["/startup.sh"]
