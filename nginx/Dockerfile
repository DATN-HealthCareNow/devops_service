FROM nginx:alpine

# Copy Nginx configuration
COPY conf.d/app.conf /etc/nginx/conf.d/default.conf

# Copy health check page
COPY html/index.html /usr/share/nginx/html/index.html

# Expose ports
EXPOSE 80 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
