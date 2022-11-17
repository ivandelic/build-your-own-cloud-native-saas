FROM node:12.2.0-alpine
WORKDIR /departments-frontend
COPY . ./
RUN npm install --only=prod
EXPOSE 3000
CMD [ "npm", "start" ]