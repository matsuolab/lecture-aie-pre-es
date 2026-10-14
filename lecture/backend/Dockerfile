# --- Etapa de compilación ---
FROM python:3.12-slim AS builder

WORKDIR /app

# Crea un entorno virtual
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
# Ejecuta los comandos en secuencia con &&
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# --- Etapa de ejecución ---
FROM python:3.12-slim AS runner
WORKDIR /app

# Copia el entorno virtual completo desde la etapa de compilación
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Coloca el código de la aplicación
COPY . /app/

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]