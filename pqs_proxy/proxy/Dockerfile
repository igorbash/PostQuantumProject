FROM openquantumsafe/nginx
USER root
COPY app/ /app/
WORKDIR /app
RUN apk add python3 py3-pip
RUN pip3 install requests
COPY start.sh .
CMD ["./start.sh"]

