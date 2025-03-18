# Although we're not building the project, as it's a simple static website, we are doing a 
# a multi-stage build to demonstrate how to do reduce the final image size
# by copying only the necessary files from the builder stage
# and using a distroless nginx image with a nonroot user to reduce the final image size and attack surface

# Build stage
FROM nginx:alpine as builder

COPY src/index.html /usr/share/nginx/html/
COPY assets/config/nginx.conf /etc/nginx/conf.d/default.conf

# Final stage using distroless nginx
FROM gcr.io/distroless/nginx:nonroot

# Copy nginx configuration and content from builder
COPY --from=builder /usr/share/nginx/html /usr/share/nginx/html
COPY --from=builder /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Use nonroot user
USER nonroot

# Command to start nginx and serve the static website
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]