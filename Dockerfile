FROM node:13
WORKDIR /app
COPY package*.json .
COPY entrypoint.sh .
COPY . .
RUN npm install
EXPOSE 3000
ENTRYPOINT ["/bin/bash", "./entrypoint.sh"]