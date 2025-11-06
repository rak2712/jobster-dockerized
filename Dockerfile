# Use an official Node.js runtime as a parent image
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the backend application files
COPY . ./

# Expose the port the backend will run on (5000)
EXPOSE 5000

# Define the command to run the backend application
CMD ["npm", "start"]
