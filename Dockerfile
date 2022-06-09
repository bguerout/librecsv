FROM alpine:latest

RUN apk update && apk add libreoffice bash

COPY convert-to-csv.sh /
RUN chmod +x /convert-to-csv.sh
ENTRYPOINT ["/convert-to-csv.sh"]

