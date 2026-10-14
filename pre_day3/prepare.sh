#!/bin/sh

# Este archivo es un programa de preparación para pre-Day3 (la parte de la práctica con Docker).
# Ejecútalo una vez antes de la clase para evitar esperas durante la sesión.
# Se guarda en pre_day3/prepare.sh dentro del repositorio; para ejecutarlo solo hacen falta
#   chmod +x pre_day3/prepare.sh
#   ./pre_day3/prepare.sh
# estos dos comandos (las mismas operaciones que aprendimos en pre-Day2).

# Si se produce un error, se detiene en ese momento (-e).
# También se detiene si se intenta utilizar una variable que no tiene un valor definido (-u).
set -eu

# [1] Agrupa en variables las versiones de la imagen de Docker y del modelo que se descargarán.
#     Los participantes no deben modificar esta sección.
IMAGE='ghcr.io/ggml-org/llama.cpp:server-v0.5.0'
MODEL_DIR='/workspaces/models'
MODEL_FILE='gemma-4-E2B-it-UD-Q4_K_XL.gguf'
MODEL_URL='https://huggingface.co/unsloth/gemma-4-E2B-it-GGUF/resolve/0314792d7f1f7e229411f620751375812bb9faf2/gemma-4-E2B-it-UD-Q4_K_XL.gguf'
MODEL_SHA256='b52f438017efaec5debf1c0d8be690571e212a07c312f1102bbce927258cfc32'
LLM_CHAT_DIR='/workspaces/llm-chat'
# Espacio libre recomendado: la descarga ocupa unos 3.5GB. Se usa como referencia 4GB (4*1024*1024 KB) para dejar margen.
REQUIRED_FREE_KB=4194304

# [2] Comprueba si es posible conectar con el servidor de Docker.
#     Si no es posible, se detiene aquí e indica qué hacer a continuación.
check_docker() {
  if ! docker version >/dev/null 2>&1; then
    printf '%s\n' 'Error: Docker no está disponible.' >&2
    printf '%s\n' 'Docker aún no ha terminado de arrancar en este Codespace o el entorno no permite utilizarlo.' >&2
    printf '%s\n' 'Espera unas decenas de segundos y vuelve a ejecutar: ./pre_day3/prepare.sh' >&2
    exit 1
  fi
}

# [3] Comprueba el espacio libre en /workspaces.
#     Si no es suficiente, se detiene aquí e indica qué hacer a continuación.
check_disk_space() {
  free_kb=$(df -Pk "$MODEL_DIR_PARENT" | awk 'NR==2 {print $4}')
  if [ "$free_kb" -lt "$REQUIRED_FREE_KB" ]; then
    printf '%s\n' 'Error: no hay suficiente espacio libre en /workspaces.' >&2
    printf '%s\n' 'Se necesitan unos 4GB libres como mínimo (imagen: unos 308MB; modelo: unos 3.2GB).' >&2
    printf '%s\n' 'Elimina los Codespaces que no utilices o los archivos innecesarios y después' >&2
    printf '%s\n' 'vuelve a ejecutar: ./pre_day3/prepare.sh' >&2
    exit 1
  fi
}

# [4] Descarga la imagen de llama.cpp. Si ya está descargada, no vuelve a descargarla.
pull_image() {
  if docker image inspect "$IMAGE" >/dev/null 2>&1; then
    printf '%s\n' "La imagen ya está descargada ($IMAGE). Se omite la descarga."
    return 0
  fi
  printf '%s\n' "Se descargará la imagen ($IMAGE). Puede tardar varios minutos."
  if ! docker pull "$IMAGE"; then
    printf '%s\n' 'Error: no se ha podido descargar la imagen.' >&2
    printf '%s\n' 'Comprueba la conexión de red y vuelve a ejecutar: ./pre_day3/prepare.sh' >&2
    exit 1
  fi
}

# [5] Comprueba si el SHA-256 del archivo es el esperado. Devuelve 0 si coincide y 1 si no coincide.
matches_sha256() {
  target_file="$1"
  [ -f "$target_file" ] || return 1
  actual=$(sha256sum "$target_file" | awk '{print $1}')
  [ "$actual" = "$MODEL_SHA256" ]
}

# [6] Descarga el archivo del modelo.
#     Si ya se ha verificado, no vuelve a descargarlo; elimina los archivos incompletos y vuelve a descargarlos.
fetch_model() {
  mkdir -p "$MODEL_DIR"
  model_path="$MODEL_DIR/$MODEL_FILE"
  tmp_path="$model_path.download"

  if matches_sha256 "$model_path"; then
    printf '%s\n' "El modelo ya está descargado y su contenido se ha verificado ($model_path). Se omite la descarga."
    return 0
  fi

  # Elimina cualquier archivo que haya quedado incompleto en el intento anterior.
  rm -f "$tmp_path"

  printf '%s\n' 'Se descargará el modelo. Puede tardar alrededor de un minuto.'
  if ! curl --fail --silent --show-error --location --output "$tmp_path" "$MODEL_URL"; then
    rm -f "$tmp_path"
    printf '%s\n' 'Error: no se ha podido descargar el modelo.' >&2
    printf '%s\n' 'Comprueba la conexión de red y vuelve a ejecutar: ./pre_day3/prepare.sh' >&2
    exit 1
  fi

  if ! matches_sha256 "$tmp_path"; then
    rm -f "$tmp_path"
    printf '%s\n' 'Error: el contenido del modelo descargado no es correcto (el SHA-256 no coincide).' >&2
    printf '%s\n' 'Es posible que se haya interrumpido la conexión. Vuelve a ejecutar: ./pre_day3/prepare.sh' >&2
    exit 1
  fi

  mv "$tmp_path" "$model_path"
  printf '%s\n' 'La descarga del modelo y la verificación de su contenido han terminado.'
}

# [7] Coloca el Dockerfile para la IA en /workspaces/llm-chat/Dockerfile.
#     Su contenido está incluido en este programa (es el mismo que el Dockerfile de la página de distribución).
place_llm_chat_dockerfile() {
  mkdir -p "$LLM_CHAT_DIR"
  cat > "$LLM_CHAT_DIR/Dockerfile" <<'DOCKERFILE'
# [1] Base (base image): una imagen que contiene el servidor de llama.cpp.
#     Se fija la versión (server-v0.5.0). Con latest, el contenido podría cambiar cada vez que se reconstruya.
FROM ghcr.io/ggml-org/llama.cpp:server-v0.5.0

# [2] Configuración (environment variable): ubicación del modelo que se cargará.
#     El archivo del modelo no se incluye en la imagen; se proporciona desde fuera en /models con -v (bind mount) de docker run.
ENV LLAMA_ARG_MODEL=/models/gemma-4-E2B-it-UD-Q4_K_XL.gguf

# [3] Configuración: puerto de escucha (port). Escucha en 0.0.0.0, puerto 8080, para permitir conexiones desde fuera del contenedor.
ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=8080

# [4] Configuración: desactiva el razonamiento (reasoning). Longitud de la conversación que puede recordar (ctx-size).
#     Límite de la longitud de cada respuesta (n-predict).
ENV LLAMA_ARG_REASONING=off
ENV LLAMA_ARG_CTX_SIZE=4096
ENV LLAMA_ARG_N_PREDICT=256

# [5] Configuración: instrucción inicial para la IA (system prompt). Si la cambias y vuelves a ejecutar docker build,
#     cambiará la forma de responder de la IA. Basta con modificar la frase entre "" de esta línea.
#     Mantén las comillas anidadas (simples en el exterior y dobles en el interior).
ENV LLAMA_ARG_UI_CONFIG='{"systemMessage":"Eres un asistente servicial. Responde brevemente."}'
DOCKERFILE
  printf '%s\n' "Se ha colocado $LLM_CHAT_DIR/Dockerfile."
}

# Orden de ejecución a partir de aquí (llama a las funciones [2] a [7] en este orden).
MODEL_DIR_PARENT=$(dirname "$MODEL_DIR")
check_docker
check_disk_space
pull_image
fetch_model
place_llm_chat_dockerfile

printf '%s\n' 'Preparación completada'
