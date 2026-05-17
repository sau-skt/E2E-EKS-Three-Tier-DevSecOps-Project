FROM node:14 AS backend
WORKDIR /usr/src/app
COPY . .
RUN npm install

FROM node:14.0.0-alpine
WORKDIR /app
COPY --from=backend /usr/src/app/node_modules ./node_modules
COPY --from=backend /usr/src/app/models ./models
COPY --from=backend /usr/src/app/routes ./routes
COPY --from=backend /usr/src/app/db.js .
COPY --from=backend /usr/src/app/index.js .
CMD ["node", "index.js"]
