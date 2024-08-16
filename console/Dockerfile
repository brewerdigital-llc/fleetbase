# ---- Build Stage ----
FROM node:18.15.0-alpine AS builder

# Set the working directory in the container to /app
WORKDIR /app

# Create the pnpm directory and set the PNPM_HOME environment variable
RUN mkdir -p ~/.pnpm
ENV PNPM_HOME /root/.pnpm
# Add the pnpm global bin to the PATH
ENV PATH /root/.pnpm/bin:$PATH

# Set environment
#ARG ENVIRONMENT=production
ENV ENVIRONMENT=development

# Copy pnpm-lock.yaml (or package.json) into the directory /app in the container
COPY console/package.json console/pnpm-lock.yaml ./
# Copy over .npmrc if applicable
COPY console/.npmr[c] ./

RUN if [ "$ENVIRONMENT" = "production" ]; then \
  apk update && apk add git openssh-client && \
  # Trust GitHub's RSA host key
  mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts; \
fi

# Copy the console directory contents into the container at /app
COPY console* .

RUN if [ "$ENVIRONMENT" = "production" ]; then \
  # Build the application
  pnpm build --environment $ENVIRONMENT && \
  npm install -g ember-cli pnpm  && \
  pnpm install; \
fi

RUN if [ "$ENVIRONMENT" = "development" ]; then \
  cp start.sh /app && \
  echo "Running in production mode"; \
  # List files in /app (or another directory) and output to the logs
  ls -l / && \
  ls -l /app; \
fi

# Install global dependencies
# ---- Serve Stage ----
FROM nginx:alpine

# Conditional block for production
RUN if [ "$ENVIRONMENT" = "production" ]; then \
  # Copy the built app to our served directory
  cp -r /app/dist /usr/share/nginx/html && \
  # Use custom nginx.conf
  cp console/nginx.conf /etc/nginx/conf.d/default.conf; \
fi

## Expose the port nginx is bound to
EXPOSE 4200

# Copy the start script
COPY --from=builder --chmod=0755 /app/start.sh ./app/start.sh

# Set the start script as the entry point
CMD ["/app/start.sh"]

