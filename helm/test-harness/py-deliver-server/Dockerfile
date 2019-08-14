FROM busybox:latest

COPY www  /var/www
#COPY ./entrypoint.sh /

EXPOSE 8085
CMD ["httpd", "-f",  "-p", "0.0.0.0:8085", "-h", "/var/www/"]
