FROM node:14 AS frontend
WORKDIR /usr/src/app
COPY . .
RUN npm install

FROM node:14.0.0-alpine
WORKDIR /app
COPY --from=frontend /usr/src/app/node_modules ./node_modules
COPY --from=frontend /usr/src/app/package.json .
COPY --from=frontend /usr/src/app/public ./public
COPY --from=frontend /usr/src/app/src ./src
CMD ["npm", "start"]
