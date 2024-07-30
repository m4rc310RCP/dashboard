# Etapa de construção (Builder Stage)
FROM node:latest as builder

WORKDIR /app

# Copie apenas os arquivos de configuração do pacote inicialmente
COPY package*.json ./

# Instale pnpm globalmente
RUN npm i -g pnpm

# Utilize o cache para node_modules
# A diretiva --mount=type=cache é específica do BuildKit
RUN --mount=type=cache,target=/root/.pnpm-store pnpm install

# Copie o restante do código da aplicação
COPY . .

# Construa a aplicação
RUN pnpm build

# Etapa de produção (Production Stage)
FROM nginx:alpine

# Defina o diretório de trabalho do Nginx
WORKDIR /usr/share/nginx/html

# Limpe o diretório HTML padrão do Nginx
RUN rm -rf ./*

# Copie os arquivos construídos da etapa anterior
COPY --from=builder /app/dist .

# Copie a configuração do Nginx
COPY --from=builder /app/nginx.conf /etc/nginx/conf.d/default.conf

# Defina o comando de entrada do Nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]

# Exponha a porta 8080
EXPOSE 8080