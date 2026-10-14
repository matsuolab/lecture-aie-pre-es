# Carpeta para los ejercicios


## Demostración de Linux
El objetivo es obtener la siguiente estructura de archivos y permisos.
Los permisos se indican con la notación simbólica que muestra `ls -la` (por ejemplo, `-rw-------`).

```estructura-de-archivos
lecture/                                        drwxr-xr-x
├── README.md                                   -rw-r--r--
├── docker-compose.yml                          -rw-r--r--
├── backend/                                     drwxr-xr-x
│   ├── Dockerfile                              -rw-r--r--
│   ├── main.py                                 -rw-r--r--
|   ├── .env                                    -rw-------  ← chmod 600 (solo el propietario, porque contiene información confidencial)
|   ├── .env.example                            -rw-r--r--  ← plantilla para compartir
│   ├── requirements.txt                        -rw-r--r--
└── frontend/                                    drwxr-xr-x
    ├── Dockerfile                              -rw-r--r--
    ├── index.html                              -rw-r--r--
    ├── package-lock.json                       -rw-r--r--
    ├── package.json                            -rw-r--r--
    ├── tsconfig.json                           -rw-r--r--
    ├── vite.config.ts                          -rw-r--r--
    └── src/                                     drwxr-xr-x
        ├── App.tsx                             -rw-r--r--
        └── main.tsx                            -rw-r--r--
```


## Demostración de Docker
Puedes iniciar un servidor de desarrollo con Docker compose.
```
cp backend/.env.example backend/.env && chmod 600 backend/.env   # Solo la primera vez
docker compose up -d --build
```

### Si al enviar aparece el error 504: «La comunicación ha fallado».
En Codespace, el cortafuegos antiguo (iptables-legacy) puede descartar la comunicación entre contenedores.
Para permitir la comunicación entre las redes de Compose (cuyos nombres empiezan por `br-`), ejecuta lo siguiente una sola vez después de iniciar el Codespace.
```
sudo iptables-legacy -I FORWARD 1 -i br-+ -o br-+ -j ACCEPT
```
- La configuración desaparece al reiniciar el Codespace (vuelve a ejecutarlo después de reiniciar).
- Para deshacer el cambio: `sudo iptables-legacy -D FORWARD -i br-+ -o br-+ -j ACCEPT`

El servidor de desarrollo está disponible en la siguiente dirección.
http://localhost:8080/