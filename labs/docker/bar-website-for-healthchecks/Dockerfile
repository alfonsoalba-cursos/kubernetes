FROM nginx:latest

COPY site /usr/share/nginx/html
COPY ready.sh /ready.sh
COPY live.sh /live.sh

RUN chmod 755 /ready.sh /live.sh