# Etapa de construção (Builder Stage)
FROM node:20 as builder

WORKDIR /app

# Copie apenas os arquivos de configuração do pacote inicialmente
COPY package*.json ./

# Instale pnpm globalmente
RUN npm i -g pnpm

# Utilize o cache para node_modules
# A diretiva --mount=type=cache é específica do BuildKit
RUN --mount=type=cache,target=/root/.pnpm-store pnpm i

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
COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf

# Crie os diretórios necessários e defina as permissões
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx \
    && chown -R nginx:nginx /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html

# Adicione o usuário não-root se ele não existir
RUN addgroup -S nginx || true && adduser -S nginx -G nginx || true

# Mude o proprietário dos arquivos para o usuário não-root
RUN chown -R nginx:nginx /usr/share/nginx/html

# Defina o usuário não-root para executar a aplicação
USER nginx

# Adicione a instrução HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8080/health || exit 1

# Defina o comando de entrada do Nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]

# Exponha a porta 8080
EXPOSE 8080