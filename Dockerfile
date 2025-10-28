FROM demonstrationorg/dhi-node:24.9.0-debian13-dev AS dev

ENV BLUEBIRD_WARNINGS=0 \
NODE_ENV=production \
NODE_NO_WARNINGS=1 \
NPM_CONFIG_LOGLEVEL=warn \
SUPPRESS_NO_CONFIG_WARNING=true

WORKDIR /app

COPY package.json ./

RUN apt-get update \
 && apt-get install -y --no-install-recommends npm \
 && npm install --no-optional \
 && npm cache clean --force \
 && apt-get remove -y npm \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

COPY . .


#-- Prod stage --
FROM demonstrationorg/dhi-node:24.9.0-debian13 AS prod

WORKDIR /app

COPY --from=dev /app /app

ENTRYPOINT ["node"]
CMD ["app.js"]
EXPOSE 3000
