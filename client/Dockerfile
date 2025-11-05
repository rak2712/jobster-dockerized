# Step 1: Build Stage
FROM node:16 AS build

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
