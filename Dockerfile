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
USER 1001  # Run as non-root (OpenShift compatible)

# Ensure Nginx has the correct permissions
RUN mkdir -p /var/cache/nginx/client_temp && \
    chmod -R 777 /var/cache/nginx && \
    chown -R 1001:0 /var/cache/nginx

# Set user to non-root for OpenShift security compliance
USER 1001

# Copy built files from Node.js stage to Nginx
COPY --from=build /app/dist/banking-portal /usr/share/nginx/html

# Copy Nginx config (without server block)
COPY nginx.conf /etc/nginx/nginx.conf

# Copy site-specific config (contains server block)
COPY default.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for OpenShift
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
