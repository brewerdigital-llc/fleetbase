# Set environment
# Development
ARG DISTRO=builder
# NOTE: if you are using a local dependency (i.e. local fleetops) you cannot use docker, just run npm start

# Production
# ARG DISTRO=nginx:alpine

# ---- Build Stage ----
FROM node:18.15.0-alpine AS builder
ENV ENVIRONMENT=development

# Set the working directory in the container to /app
WORKDIR /app

# Create the pnpm directory and set the PNPM_HOME environment variable
RUN mkdir -p ~/.pnpm
ENV PNPM_HOME /root/.pnpm
# Add the pnpm global bin to the PATH
ENV PATH /root/.pnpm/bin:$PATH


# Copy pnpm-lock.yaml (or package.json) into the directory /app in the container
COPY console/package.json console/pnpm-lock.yaml ./
# Copy over .npmrc if applicable
COPY console/.npmr[c] ./

# Install global dependencies
RUN if [ "$ENVIRONMENT" = "production" ]; then \
  apk update && apk add git openssh-client && \
  # Trust GitHub's RSA host key
  mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts; \
fi

RUN npm install -g ember-cli pnpm

# Copy the console directory contents into the container at /app
COPY console/* .
RUN pnpm install

RUN if [ "$ENVIRONMENT" = "production" ]; then pnpm build --environment $ENVIRONMENT; fi
# ---- Serve Stage ----
FROM $DISTRO

# Conditional block for production
RUN if [ "$ENVIRONMENT" = "production" ]; then \
  # Copy the built app to our served directory
  cp -r /app/dist /usr/share/nginx/html && \
# Copy the start script
  cp /app/start.sh ./app/start.sh && \
  # Use custom nginx.conf \
  cp console/nginx.conf /etc/nginx/conf.d/default.conf; \
fi

## Expose the port nginx is bound to
EXPOSE 4200

COPY --from=builder --chmod=0755 /app/start.sh ./app/start.sh
RUN ls -a /app/node_modules
RUN ls -a /app/node_modules/.pnpm

# Set the start script as the entry point
CMD ["/app/start.sh"]

