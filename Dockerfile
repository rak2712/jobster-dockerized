# Use Node.js base image
FROM node:16

# Set working directory
WORKDIR /app

# Install backend dependencies
COPY backend/package.json backend/package-lock.json ./
RUN npm install

# Copy the rest of the backend code
COPY backend/ ./

# Expose port for the backend (assume it runs on port 5000)
EXPOSE 5000

# Start the backend app
CMD ["npm", "start"]
