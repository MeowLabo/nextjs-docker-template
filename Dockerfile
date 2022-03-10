FROM openfaas/of-watchdog:0.9.3 as watchdog

FROM node:17-alpine as ship

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

RUN addgroup -S app && adduser -S -g app app

ENV NPM_CONFIG_LOGLEVEL warn

RUN mkdir -p /home/app

WORKDIR /home/app

RUN yarn

COPY . /home/app/

RUN yarn && yarn build \
    && npm prune --production
RUN chown -R app:app /home/app && chmod 777 /tmp

USER app

ENV cgi_headers="true"
ENV fprocess="yarn start"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:3000"

ENV exec_timeout="10s"
ENV write_timeout="15s"
ENV read_timeout="15s"

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]