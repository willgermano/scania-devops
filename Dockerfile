# Usa Node 24.13.1 para compilar o Angular 22, pois essa versao atende ao requisito do Angular CLI 22.
FROM node:24.13.1-alpine AS build

# Define /app como pasta de trabalho dentro da imagem de build.
WORKDIR /app

# Copia package.json e package-lock.json primeiro para aproveitar cache do Docker na instalacao das dependencias.
COPY package*.json ./

# Instala as dependencias exatamente como definido no package-lock.json.
RUN npm ci

# Copia todo o codigo fonte do projeto Angular para dentro da imagem.
COPY . .

# Gera a versao de producao do Angular dentro da pasta dist.
RUN npm run build

# Usa Nginx leve para servir os arquivos estaticos gerados pelo Angular.
FROM nginx:alpine AS runtime

# Copia a configuracao do Nginx que serve o Angular e encaminha /api para a API Docker.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia o build final do Angular para a pasta publica padrao do Nginx.
COPY --from=build /app/dist/frontend-teste-docker2/browser /usr/share/nginx/html

# Informa que o container servira a aplicacao pela porta 80.
EXPOSE 80

# Inicia o Nginx em primeiro plano para manter o container em execucao.
CMD ["nginx", "-g", "daemon off;"]

# link para testar: http://localhost:4201
