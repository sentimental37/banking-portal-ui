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

# Copy Nginx config (without server block)
COPY nginx.conf /etc/nginx/nginx.conf

# Copy site-specific config (contains server block)
COPY default.conf /etc/nginx/conf.d/default.conf

RUN chmod -R 777 /etc/nginx /usr/share/nginx/html
RUN mkdir -p /var/cache/nginx/client_temp
RUN chmod -R 777 /var/cache/nginx

# Change ownership to a non-root user (OpenShift compatible)
RUN chown -R 1001:0 /usr/share/nginx/html /var/cache/nginx /var/run /etc/nginx \
    && chmod -R g+w /usr/share/nginx/html /var/cache/nginx /var/run /etc/nginx

# Use a non-root user
USER 1001


# Expose port 80 for OpenShift
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
