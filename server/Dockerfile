# ---- Base Node ----
FROM alpine:3.13 AS base
# install node
RUN apk add --update --no-cache nodejs npm tini
# using non root user
RUN addgroup -S servergroup && adduser -S serveruser -G servergroup
USER serveruser
# create and set working directory
RUN mkdir /home/serveruser/app
WORKDIR /home/serveruser/app
# copy project file
COPY package.json .
# Set tini as entrypoint and run other programs under it
ENTRYPOINT ["/sbin/tini", "--"]

# ---- Dependencies ----
FROM base AS dependencies
# install node packages
RUN npm set progress=false && npm config set depth 0 && npm install --only=prod 
# copy production node_modules for next stage use
RUN cp -R node_modules prod_node_modules

# ---- Release ----
FROM base AS release
# copy production node_modules from dependencies stage
COPY --from=dependencies /home/serveruser/app/prod_node_modules ./node_modules
# copy app sources
COPY . .
# expose port and define CMD
EXPOSE 8080
CMD [ "npm", "start" ]