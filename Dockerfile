# Unofficial fivefilters Full-Text RSS service
# Enriches third-party RSS feeds with full text articles
# https://bitbucket.org/fivefilters/full-text-rss

FROM	tutum/apache-php

ENV	BUILD_DEPS \
	git


# APT proxy configuration
# Unfortunately, www-proxy.fkie.fraunhofer.de does not seem to work here :/
RUN	echo 'Acquire::http::proxy "http://128.7.3.56:3128/";' > /etc/apt/apt.conf && \
	echo 'Acquire::https::proxy "https://128.7.3.56:3128/";' >> /etc/apt/apt.conf


RUN	apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	$BUILD_DEPS 


# GIT proxy configuration
RUN	git config --global http.proxy https://128.7.3.56:3128


# Clone the source
RUN	cd /var/www/html/ && \
	git clone https://bitbucket.org/fivefilters/full-text-rss.git

# Reset to specific version, move files to WWW-root
# https://bitbucket.org/fivefilters/full-text-rss/commits/
RUN	cd /var/www/html/full-text-rss/ && \
	git reset --hard e7753953f6dd5d69b889956f42e130d2d62f6514 && \
	mv -fv * ../


# Clean up
# Taken from https://www.dajobe.org/blog/2015/04/18/making-debian-docker-images-smaller/
RUN	apt-get remove -y $BUILD_DEPS && \
	rm -rf /var/lib/apt/lists/


# Enable Full-Text-Feed RSS caching 
RUN	chmod -Rv 777 /var/www/html/cache


COPY	custom_config.php /var/www/html/

