# Use an official Node.js runtime as a parent image
FROM node:16
# Set the working directory inside the container
WORKDIR /app
# Copy package.json and package-lock.json first
COPY package*.json ./
# Install dependencies
RUN npm install
# Copy the rest of the application files
COPY . .

#EXPOSE the port that the server runs on
EXPOSE 5000

#DEFINE THE COMMAND TO RUN THE application

CMD ["npm","start"]