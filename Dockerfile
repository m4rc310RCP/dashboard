FROM node:latest as builder

WORKDIR /app
COPY . /app

RUN npm install -g pnpm

RUN pnpm install && pnpm build

COPY . .

RUN pnpm run build 
#-------
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

ENTRYPOINT ["nginx", "-g", "daemon off;"]
EXPOSE 8080