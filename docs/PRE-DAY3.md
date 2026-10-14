# Tarea de preparación para la próxima sesión

En esta tarea utilizaremos `pre_day2/template.md` y `pre_day2/generate.sh`, que preparaste la vez anterior. El tiempo total estimado para la tarea es de 30 minutos. No hay que entregar nada. Después de la tarea también está la «Preparación para la próxima sesión», que consiste en descargar por adelantado los archivos grandes que utilizaremos. Es un trabajo aparte y no está incluido en los 30 minutos.

## Tarea

Añade al informe el campo «Máquina que ejecutó el script». Después, genera el informe tanto en tu Codespace como en GitHub Actions y compara los dos valores registrados. El valor generado en Codespace se sobrescribirá al incorporar el resultado de GitHub, así que anótalo primero.

Las operaciones son las mismas que en la práctica de hoy. Sigue estas condiciones:

- Crea una rama para la tarea a partir de la misma `master` de hoy y trabaja en ella.
- Integra los cambios en `master` mediante un Pull Request.
- Haz commit únicamente de los tres archivos de `pre_day2`: `template.md`, `generate.sh` y `report.md`.
- Tras integrarlos, incorpora también el resultado de GitHub en la rama `master` del Codespace.

## Líneas que debes añadir

Las líneas que debes añadir están en los siguientes bloques. Copia su contenido exactamente en la posición indicada.

### template.md

Añádela después de la línea «Fecha y hora de comprobación (UTC)».

```
Máquina que ejecutó el script: {{MACHINE_NAME}}
```

### generate.sh

Añade estas líneas después de la línea `checked_at=`. Las líneas que empiezan por `#` son comentarios que explican lo que hace el script.

```
    # Guarda en machine_name el nombre que identifica a la máquina que ejecuta el script.
    # /proc/sys/kernel/hostname es el archivo donde la máquina escribe su propio nombre identificador.
    machine_name=$(cat /proc/sys/kernel/hostname)
```

Añade la siguiente línea antes de la línea de `sed` que sustituye `{{HTTP_STATUS}}`. Indica que el marcador `{{MACHINE_NAME}}` añadido a `template.md` debe sustituirse por el nombre identificador obtenido antes.

```
        -e "s|{{MACHINE_NAME}}|$machine_name|g" \
```

Esta línea, junto con las líneas de `sed` que la rodean, forma un único comando. El carácter `\` (barra inversa) al final de la línea indica que el comando continúa en la línea siguiente, así que debes incluirlo. Tampoco añadas líneas de comentarios justo antes o después de esta línea. Si las introduces en medio del comando, este quedará interrumpido ahí.

## Precauciones

- No borres el `\` al final de la línea de `sed` que has añadido a `generate.sh`. Si lo borras, `./generate.sh` se quedará esperando sin mostrar nada. En ese caso, mantén pulsada la tecla `Ctrl` y pulsa `C` para interrumpirlo; después, añade el `\`, vuelve a guardar y ejecútalo de nuevo.
- Si algún paso de Actions aparece en rojo, lee el error del primer paso en rojo. Las causas más frecuentes son errores al copiar las líneas añadidas o colocarlas en una posición incorrecta. Como el Pull Request ya está integrado, no podrás corregirlo mediante ese mismo Pull Request. Actualiza tu `master`, crea una rama nueva, corrige el problema en ella e integra los cambios siguiendo de nuevo el mismo proceso.
- Es correcto que el valor del Codespace sea distinto al de GitHub Actions. Si son iguales, comprueba que no te hayas equivocado al anotarlo.

## Autoevaluación

La tarea estará completa cuando se cumplan todos los puntos siguientes. Se indica cómo comprobar cada uno; revísalos uno a uno.

- [ ] Los cambios se han integrado mediante un Pull Request desde la rama de la tarea y solo se han modificado los tres archivos de `pre_day2`. (Compruébalo en `Files changed` de ese Pull Request).
- [ ] El informe se ha generado correctamente en GitHub Actions. (En `Actions` del repositorio, la ejecución de `Update report` que comenzó después de integrar los cambios aparece en verde. Justo después de integrarlos aparecerá en curso; espera a que termine).
- [ ] Has incorporado el resultado de GitHub en la rama `master` del Codespace. (Al ejecutar `git status`, estás en `master` y no hay cambios pendientes de commit).
- [ ] `report.md` contiene una línea «Máquina que ejecutó el script: » seguida de un valor. (Muéstralo con `cat pre_day2/report.md` y comprueba que la línea existe y que ya no contiene `{{MACHINE_NAME}}`).
- [ ] Ese valor es distinto del que anotaste al generar el informe en Codespace. (El valor del `report.md` incorporado se ha generado en GitHub Actions).

## Preparación para la próxima sesión

A partir de aquí se trata de preparar la próxima sesión, al margen de la tarea. Descargaremos por adelantado los archivos grandes que utilizaremos.

El repositorio ya incluye el programa de preparación `pre_day3/prepare.sh`. En la terminal del Codespace, ejecuta lo siguiente desde la carpeta raíz del repositorio.

```sh
./pre_day3/prepare.sh
```

Puede tardar varios minutos. Cuando aparezca `Preparación completada`, habrá terminado. Si se detiene con un error, sigue la siguiente acción indicada en el mensaje (esperar un rato, liberar espacio, volver a ejecutarlo, etc.).

Si no tienes tiempo para ejecutarlo, podrás continuar ejecutando el mismo comando al principio de la próxima sesión. Sin embargo, la descarga puede tardar hasta unos 10 minutos, así que reserva ese tiempo adicional para la próxima sesión.

En la próxima sesión ejecutaremos dentro de Docker el mecanismo de «Máquina que ejecutó el script» que hemos registrado esta vez.
