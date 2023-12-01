FROM node:alpine

WORKDIR /usr/src/app

COPY package.json package-lock.json index.mjs ./

RUN npm install

COPY . .

CMD ["node", "index.mjs"]
