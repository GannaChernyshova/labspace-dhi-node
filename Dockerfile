FROM node:24-trixie-slim AS dev

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
FROM node:24-trixie-slim AS prod

WORKDIR /app

COPY --from=dev /app /app

ENTRYPOINT ["node"]
CMD ["app.js"]
EXPOSE 3000
