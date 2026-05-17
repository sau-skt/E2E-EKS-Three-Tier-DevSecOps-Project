FROM node:14 AS frontend
WORKDIR /usr/src/app
COPY ../../../app/frontend/. .
RUN npm install

FROM node:14.0.0-alpine
WORKDIR /app
COPY --from=frontend /usr/src/app/node-modules ./node-modules
COPY --from=frontend /usr/src/app/public .
COPY --from=frontend /usr/src/app/src .
CMD ["npm", "start"]
