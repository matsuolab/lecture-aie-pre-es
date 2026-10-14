# --- Etapa de compilación ---
FROM node:22-slim AS builder

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
RUN npm run build

# --- Etapa de ejecución ---
# Sirve los archivos estáticos compilados con una imagen ligera de nginx
FROM nginx:alpine AS runner

# Coloca solo el resultado de la compilación de vite (dist) en el directorio público de nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuración del proxy inverso de /app/api hacia el contenedor backend
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Escucha en el puerto 80 (configuración predeterminada de la imagen de nginx)
EXPOSE 80
