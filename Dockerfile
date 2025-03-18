# Use a standard, well-tested NGINX image for reliability
FROM nginx:alpine

# Copy website content
COPY src/index.html /usr/share/nginx/html/
COPY assets/config/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Command to start nginx and serve the static website
CMD ["nginx", "-g", "daemon off;"]