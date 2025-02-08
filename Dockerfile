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

RUN chmod -R 777 /etc/nginx /usr/share/nginx/html
RUN mkdir -p /var/cache/nginx/client_temp
RUN chmod -R 777 /var/cache/nginx

USER 1001  # Run as non-root (OpenShift compatible)

# Copy built files from Node.js stage to Nginx
COPY --from=build /app/dist/banking-portal /usr/share/nginx/html

# Copy Nginx config (without server block)
COPY nginx.conf /etc/nginx/nginx.conf

# Copy site-specific config (contains server block)
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for OpenShift
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
