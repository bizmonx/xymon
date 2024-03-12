FROM --platform=linux/amd64 redhat/ubi9:latest

RUN dnf swap -y curl-minimal curl 
# RUN  dnf install -y libssh libpsl libbrotli \
#     && dnf download curl libcurl \
#     && rpm -Uvh --nodeps --replacefiles "*curl*$( uname -i ).rpm" \
#     && dnf remove -y libcurl-minimal curl-minimal

RUN dnf install -y rrdtool httpd wget pcre make gcc gcc-c++ tar pcre-devel openssl-devel \
    zlib-devel procps-ng nmap-ncat net-tools git hostname vim \
    && dnf clean all

RUN cd /tmp \
    && curl https://rpmfind.net/linux/centos-stream/9-stream/BaseOS/x86_64/os/Packages/libtirpc-1.3.3-6.el9.x86_64.rpm \
    -o libtirpc-1.3.3-6.el9.x86_64.rpm \
    && curl https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/libtirpc-devel-1.3.3-6.el9.x86_64.rpm \
    -o libtirpc-devel-1.3.3-6.el9.x86_64.rpm \
    && dnf install -y ./libtirpc-1.3.3-6.el9.x86_64.rpm \
            ./libtirpc-devel-1.3.3-6.el9.x86_64.rpm \
    && rm -rf libtirpc*


RUN cd /tmp \
    && wget https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/rrdtool-devel-1.7.2-21.el9.x86_64.rpm \
    && dnf -y install rrdtool-devel-1.7.2-21.el9.x86_64.rpm && rm -rf rrdtool-devel-1.7.2-21.el9.x86_64.rpm


RUN useradd -s /bin/bash -M xymon && mkdir /home/xymon && chown -R xymon:xymon /home/xymon

RUN mkdir /home/build && cd /home/build && git clone https://github.com/bizmonx/xymon.git \
    && cd /home/build/xymon

ADD Makefile /home/build/xymon/Makefile

ENV LD_LIBRARY_PATH=/usr/local/lib

RUN cd /home/build/xymon && chmod +rx /home/xymon -R && make && make install

RUN cp /home/xymon/server/etc/xymon-apache.conf /etc/httpd/conf.d/ 
# RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf/httpd.conf
# RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/httpd/conf.modules.d/00-base.conf


#RUN sed -i 's/^Group apache/Group xymon/' /etc/httpd/conf/httpd.conf
##RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf

RUN echo "Mutex posixsem" >> /etc/httpd/conf/httpd.conf
#RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf

RUN chown -R xymon:xymon /var/run/httpd /var/www \
    /run/httpd /etc/httpd /var/log/httpd

# ENV TEST=0
# ADD ./scripts /home/xymon/scripts
# RUN chmod +rx /home/xymon/scripts/ -R

# ADD ./web/css/* /home/xymon/server/www/css/
# ADD ./web/etc/xymonmenu.cfg /home/xymon/server/etc/
# ADD ./web/*.txt /home/xymon/templates/
# COPY web/img/*.gif /home/xymon/server/www/gifs/

# RUN chown xymon:xymon /home/xymon -R && chmod +w /home/xymon -R


# EXPOSE 8080
# EXPOSE 1984
# EXPOSE 1976

# USER xymon
# WORKDIR /home/xymon

# RUN git clone https://github.com/bizmonx/bizmonx-gateway.git &&\
#    chmod +rx /home/xymon/bizmonx-gateway/bin/linux-amd64/bizmonx-gateway

# ENV XYMON_HOST=127.0.0.1 XYMON_PORT=1984

# # Xymon Branding and config

# # allow cgi scripts to run
# RUN echo 'XYMON_NOCSPHEADER="none"' >> /home/xymon/server/etc/xymonserver.cfg

# # change eighties vibe
# RUN sed -i 's/^XYMONBODYCSS=.*/XYMONBODYCSS=\"\$XYMONSERVERWWWURL\/css\/xymonbody\.css\"/'			/home/xymon/server/etc/xymonserver.cfg
# RUN sed -i 's/^XYMONBODYMENUCSS=.*/XYMONBODYMENUCSS=\"\$XYMONSERVERWWWURL\/css\/xymonmenu\-blue\.css\"/' /home/xymon/server/etc/xymonserver.cfg

# # size of rrd graphs
# RUN sed -i 's/^RRDHEIGHT.*/RRDHEIGHT=\"360\"/'  /home/xymon/server/etc/xymonserver.cfg
# RUN sed -i 's/^RRDWIDTH.*/RRDWIDTH=\"1152\"/'  /home/xymon/server/etc/xymonserver.cfg

# # status icon size
# RUN sed -i 's/^DOTHEIGHT.*/DOTHEIGHT=\"22\"/'  /home/xymon/server/etc/xymonserver.cfg
# RUN sed -i 's/^DOTWIDTH.*/DOTWIDTH=\"22\"/'  /home/xymon/server/etc/xymonserver.cfg

# # we're doing html5
# RUN find /home/xymon/server/web -type f -name '*header' -exec \
#     sed -i 's/<!DOCTYPE HTML PUBLIC "-\/\/W3C\/\/DTD HTML 4.0\/\/EN">/<!DOCTYPE html>/' {} \;

# # remove html cookie management
# RUN find /home/xymon/server/web -type f -name '*header' -exec sed -i '/Set-Cookie/d' {} \;

# # change header line font
# RUN find /home/xymon/server/web -type f -name '*header' -exec sed -i 's/Arial/Times New Roman/' {} \;

# # add bootstrap magic
# RUN tac /home/xymon/templates/header_add_bs.txt > /home/xymon/templates/reversed-header_add_bs.txt && \
#      while read -r line; do \
#         sed -i "/<\!-- Styles for the Xymon body  -->/i $line" /home/xymon/server/web/*header; \
#     done < /home/xymon/templates/reversed-header_add_bs.txt

# # add our own css
# RUN tac /home/xymon/templates/header_add_custom_style.txt > /home/xymon/templates/reversed-header_add_custom_style.txt && \
#     while read -r line; do \
#         sed -i "/<link rel=\"stylesheet\" type=\"text\/css\" href=\"&XYMONBODYMENUCSS\">/a $line" /home/xymon/server/web/*header; \
#     done < /home/xymon/templates/reversed-header_add_custom_style.txt

# # inject some javascript to manage various stuff, ie add bootstrap button classes to input submit
# RUN for file in /home/xymon/server/web/*footer; do \
#         perl -i -pe 'BEGIN { $content = `cat /home/xymon/templates/footer_add_js.txt`; } s|</BODY>|${content}</BODY>|' "$file"; \
#     done

# # set timezone
# ENV TZ=Europe/Brussels
# CMD ["/home/xymon/scripts/startup-ubi.sh"]


# #USER xymon

 

