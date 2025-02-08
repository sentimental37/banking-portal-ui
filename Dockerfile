# Use Node.js to build the Angular app
FROM node:22 AS build

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application files
COPY . .

# Build Angular app in production mode
RUN npm run build -- --configuration production

# Use Nginx to serve the built files
FROM nginx:alpine

# Copy built files from Node.js stage to Nginx
COPY --from=build /app/dist/banking-portal /usr/share/nginx/html

# Copy custom Nginx config (if needed)
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80 for OpenShift
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
