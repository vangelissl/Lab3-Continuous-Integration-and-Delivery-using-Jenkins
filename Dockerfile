FROM node:7.8.0
WORKDIR /opt
COPY . /opt
RUN npm install
CMD ["npm", "run", "start"]