# Step 1: Build Stage
FROM node:16 AS build
# Use Node.js as the base image
FROM node:18-alpine as build

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm i

# Copy the rest of the code
COPY . .

# Build the app
RUN npm run build

# Production stage
FROM nginx:alpine

# Copy built assets from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Add nginx configuration if needed
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY client/package.json client/package-lock.json ./

# Install frontend dependencies
RUN npm install

# Copy the rest of the application
COPY client/ ./

# Build the frontend app
RUN npm run build

# Step 2: Production Stage
FROM nginx:alpine

# Copy build files from the previous stage to Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Expose port
EXPOSE 80

# Command to run Nginx server
CMD ["nginx", "-g", "daemon off;"]
