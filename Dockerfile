FROM alpine:edge
LABEL maintainer="dev@jpillora.com"
# fetch dnsmasq and webproc binary
RUN apk update \
	&& apk --no-cache add dnsmasq \
	&& apk add --no-cache --virtual .build-deps curl \
	# download the latest version release
	&& curl -s https://api.github.com/repos/jpillora/webproc/releases/latest | grep "browser_download_url" | \
		grep "linux_amd64" | cut -d '"' -f 4 | xargs -n 1 curl -sSL | gzip -d - > /usr/local/bin/webproc \
	&& chmod +x /usr/local/bin/webproc \
	&& apk del .build-deps \
	&& rm -rf /var/cache/apk/*
#configure dnsmasq
RUN mkdir -p /etc/default/
RUN echo -e "ENABLED=1\nIGNORE_RESOLVCONF=yes" > /etc/default/dnsmasq
COPY dnsmasq.conf /etc/dnsmasq.conf
#run!
ENTRYPOINT ["webproc","--config","/etc/dnsmasq.conf","--","dnsmasq","--no-daemon"]
