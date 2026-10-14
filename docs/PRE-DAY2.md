# Tarea de preparación para la próxima sesión

En la próxima sesión comprobaremos la respuesta de una página web y reuniremos el resultado y la fecha y hora en un informe. Ejecutaremos este proceso en nuestro propio repositorio. Prepara en tu Codespace los dos archivos que servirán de base. Se necesitan unos 10 minutos. No hay que entregar nada.

## Qué preparar

Crea los siguientes dos archivos dentro de una carpeta llamada `pre_day2`.

- `pre_day2/template.md` — La plantilla con el texto del informe
- `pre_day2/generate.sh` — El proceso que genera el informe a partir de la plantilla

El contenido está más abajo en esta página. Lo leeremos y ejecutaremos en la próxima sesión. Por ahora, basta con prepararlo.

## Pasos a seguir

1. Abre el Codespace que has utilizado hoy. Si la pestaña sigue abierta, vuelve a ella. Si la has cerrado, abre en GitHub la página de tu repositorio y, como hoy, selecciona `Codespaces` en `Code`. Aparecerá en la lista el Codespace que has creado hoy; haz clic en él. No crees uno nuevo.
2. En la lista de archivos, crea el nuevo archivo `pre_day2/template.md`. La siguiente sección explica cómo hacerlo.
3. Copia y pega el contenido del bloque «template.md» que aparece más abajo y guárdalo como has hecho hoy.
4. Crea y guarda también `pre_day2/generate.sh` siguiendo los mismos pasos.
5. Abre los dos archivos y compara su contenido con los bloques de esta página para comprobar que coinciden.

Esta vez puedes continuar en master sin crear una rama. Haremos el commit en la próxima sesión.

## Cómo crear un archivo nuevo (operación que no hemos visto en la práctica de hoy)

1. Haz clic con el botón derecho en la fila con el nombre de tu repositorio, en la parte superior de la lista de archivos (aparece en mayúsculas).
2. En el menú que aparece, selecciona `New File...` (archivo nuevo). Aparecerá un campo para introducir el nombre.
3. Escribe `pre_day2/template.md` y pulsa Enter. Se crearán a la vez la carpeta `pre_day2` y el archivo que contiene, y se abrirá un editor vacío.

Si la pantalla es distinta, busca en la lista de archivos la opción equivalente a «archivo nuevo». También puedes abrir el mismo menú haciendo clic con el botón derecho en el espacio vacío situado debajo de los archivos. El editor del Codespace se llama VS Code. Guía oficial de la interfaz: [User Interface — Explorer (VS Code Docs)](https://code.visualstudio.com/docs/editing/getting-started/userinterface#_explorer-view)

## Contenido que debes pegar

Pega solo el contenido de los bloques. No incluyas el nombre del archivo ni los símbolos que delimitan el bloque. No lo pegues en la terminal. Esta vez no vamos a ejecutarlo.

### template.md

```markdown
# Informe de comprobación de una página web

Página: https://example.com/
Fecha y hora de comprobación (UTC): {{CHECKED_AT}}
Código de estado HTTP: {{HTTP_STATUS}}

Este informe se genera a partir de la plantilla y los resultados de la comprobación.
```

### generate.sh

```sh
#!/bin/sh

# Este archivo es un script que crea un informe con los resultados de comprobar una página web.
# El #! de la primera línea indica que este contenido debe ejecutarse con el programa sh.
# Desde # hasta el final de la línea son comentarios que no se ejecutan.

# Si se produce un error, se detiene en ese momento (-e).
# También se detiene si se intenta utilizar una variable que no tiene un valor definido (-u).
set -eu

# Cambia a la carpeta donde se encuentra este script.
# $0 es la ruta de este archivo; dirname es el comando que extrae solo el nombre de la carpeta.
# Así se puede leer el archivo template.md de la misma carpeta, desde dondequiera que se ejecute.
cd "$(dirname "$0")"

# case elige qué hacer según el número de argumentos añadidos al ejecutar el script.
# $# es el número de argumentos añadidos.
case "$#" in
  # 0 corresponde al caso en que se ejecuta sin añadir ningún argumento.
  0)
    # [1] Accede a la página web y guarda el código de estado HTTP en http_status.
    #     Trata los fallos como errores, limita la espera a 30 segundos y no guarda el cuerpo de la respuesta.
    http_status=$(curl --fail --silent --show-error --location --max-time 30 \
      --output /dev/null --write-out '%{http_code}' https://example.com/)

    # [2] Guarda en checked_at la fecha y hora de la comprobación en UTC.
    checked_at=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

    # [3] Sustituye los dos marcadores de template.md por los valores anteriores y escribe el resultado en report.md.
    #     Se usa | como separador para que los valores que contienen / no rompan la sustitución.
    sed -e "s|{{CHECKED_AT}}|$checked_at|g" \
        -e "s|{{HTTP_STATUS}}|$http_status|g" template.md > report.md

    printf '%s\n' 'Se ha generado report.md.'
    # ;; termina el procesamiento de este caso.
    ;;

  # 1 corresponde al caso en que se ejecuta añadiendo un argumento.
  1)
    # $1 es el primer argumento añadido al ejecutar el script.
    if [ "$1" != "setup-actions" ]; then
      printf '%s\n' 'Uso: ./generate.sh o ./generate.sh setup-actions' >&2
      exit 2
    fi
    # Crea la carpeta para la configuración de ejecución automática. Si ya existe, la utiliza tal cual.
    mkdir -p ../.github/workflows
    # Escribe en el archivo, sin cambios, desde la siguiente línea hasta la anterior a WORKFLOW.
    cat > ../.github/workflows/update-report.yml <<'WORKFLOW'
name: Update report

on:
  push:
    branches: [master]
    paths:
      - pre_day2/template.md
      - pre_day2/generate.sh
      - .github/workflows/update-report.yml
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update-report:
    runs-on: ubuntu-latest
    steps:
      - name: Check out the repository
        uses: actions/checkout@v7

      - name: Check required tools
        run: |
          command -v sh
          command -v sed
          command -v date
          command -v curl

      - name: Generate the report
        run: |
          chmod +x pre_day2/generate.sh
          ./pre_day2/generate.sh

      - name: Commit the changed report
        run: |
          if [ -z "$(git status --porcelain -- pre_day2/report.md)" ]; then
            echo "No hay cambios en report.md."
            exit 0
          fi
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add pre_day2/report.md
          git commit -m "chore: update report"
          git push
WORKFLOW
    # Muestra en pantalla que se ha escrito el archivo.
    printf '%s\n' 'Se ha creado .github/workflows/update-report.yml.'
    ;;

  # * corresponde a los casos que no coinciden con ninguno de los dos anteriores.
  *)
    printf '%s\n' 'Uso: ./generate.sh o ./generate.sh setup-actions' >&2
    exit 2
    ;;
# esac termina todo el bloque case.
esac
```

## Resultado esperado

- En la lista de archivos, hay dos archivos dentro de `pre_day2`; al abrirlos, su contenido coincide con los bloques de esta página.
- Al realizar la operación que has usado hoy para comprobar los nombres de los archivos modificados, aparece `pre_day2/`. Como son archivos nuevos, aparecen bajo un encabezado distinto al de hoy, pero basta con que veas `pre_day2/`. Están guardados, pero todavía no se ha hecho un commit. Lo haremos en la próxima sesión, así que por ahora has terminado.
- En la próxima sesión empezaremos desde este Codespace. Consérvalo sin eliminarlo. Si ha desaparecido, crea uno nuevo siguiendo los mismos pasos que hoy y vuelve a crear los dos archivos con las instrucciones de esta página.
