---
type: bitacora
title: "Bitácora: setup Ollama local"
created: 2026-05-19
updated: 2026-08-17
tags:
    - opencode
    - ollama
    - systemd
    - bitacora
    - debian
    - gpu
status: developing
related:
    - "[[Guía montar OpenCode]]"
sources: []
---

# Bitácora: setup del servidor Ollama local

Crónica real de la sesión de montaje (qué se hizo, qué falló y cómo quedó el sistema). La guía paso a paso está en [[Guía montar OpenCode]].

## Objetivo inicial

Arquitectura: portátil con terminal (OpenCode) ↔ red local (HTTP API estilo OpenAI) ↔ servidor en casa con GPU (RTX 3060 6GB) ejecutando Ollama con modelo local.

```text
OpenCode (portátil)
        ↓
HTTP API
        ↓
Ollama (servidor casa)
        ↓
RTX 3060 6GB
        ↓
Modelo local (Qwen / otros)
```

## Problemas que aparecieron y soluciones

1. **Servicio systemd no existía** — Ollama estaba instalado pero no como servicio.
   👉 Solución: crear manualmente `/etc/systemd/system/ollama.service`.

2. **Error de ruta del binario** — se intentó usar `/usr/local/bin/ollama`, pero el binario real estaba en otra ruta.
   👉 Se corrigió con `which ollama` para localizar la ruta correcta.

3. **Conflicto de procesos** — Ollama se ejecutaba manualmente y el servicio systemd también intentaba arrancarlo: conflictos, reinicios y estados raros.
   👉 Solución: `pkill ollama` + `systemctl restart ollama`.

4. **Ollama solo escuchaba en localhost** — inicialmente `127.0.0.1:11434`, lo que impedía el acceso desde el portátil.
   👉 Solución en systemd: `Environment="OLLAMA_HOST=0.0.0.0:11434"`.

5. **Modelo no disponible desde el cliente** — desde el portátil devolvía `{"models":[]}`. No era un error de red: simplemente no había modelos descargados o visibles en ese servicio.
   👉 Descargar el modelo en el servicio correcto.

## Estado final del sistema

**Servidor (Debian + RTX 3060 6GB)**

- ✔ Ollama instalado
- ✔ Servicio systemd creado
- ✔ Escuchando en red (`*:11434`)
- ✔ Acceso desde LAN funcionando
- ✔ Modelo descargado (`gemma4:e4b` inicialmente)

**Cliente (Fedora portátil)**

- ✔ Puede acceder al servidor: `curl http://192.168.5.89:11434/api/tags`
- ✔ Ya recibe respuesta JSON
- ✔ OpenCode configurado para usar Ollama remoto

> [!contradiction] Contradicción con [[Guía montar OpenCode]]
> La guía recomienda **Ubuntu Server 24.04** como SO del servidor, pero la instalación real se realizó sobre **Debian**. La guía es la opción ideal; la bitácora refleja lo ejecutado.

## Modelo recomendado para la GPU (6GB VRAM)

- ✔ **Mejor opción:** `qwen2.5-coder:7b`
- ✔ **Alternativa ligera:** `qwen2.5-coder:3b`
- ❌ **Evitar:** modelos 14B+ y modelos grandes tipo Gemma (pesados)

## Cómo se usa ahora

1. **Enciendes el servidor** → con systemd, Ollama arranca automáticamente.
2. **Verificas estado:** `systemctl status ollama` → debe salir `active (running)`.
3. **Usas desde el portátil:** `opencode`, o directamente la API con `curl http://192.168.5.89:11434/api/generate`.

## Flujo final de trabajo

```text
Encender servidor → systemd arranca Ollama → API disponible en 11434
→ Portátil (OpenCode) envía prompts → GPU 3060 procesa → Respuesta en terminal
```

## Puntos clave aprendidos

- `systemd` necesita la ruta correcta del binario.
- Ollama por defecto solo escucha en `localhost`.
- Puede haber procesos duplicados si no se controla (manual + servicio).
- OpenCode solo es cliente, no ejecuta modelos.
- El rendimiento depende totalmente del modelo elegido.

## Estado actual

👉 Funcional · Acceso remoto OK · API operativa · GPU integrada correctamente
👉 Falta solo optimizar el modelo para coding (Qwen 7B recomendado)

## Siguiente nivel (mejoras posibles)

- Streaming más rápido en OpenCode
- Auto-reconnect si el servidor cae
- Switch automático entre modelos (3B ↔ 7B)
- Modo "agent coder" tipo Cursor/Claude Code real (agentes que editan código automáticamente)

## Conexiones

- [[Guía montar OpenCode]] — versión estructurada y paso a paso del montaje
- [[Fedora en MacBook Pro T2]] — mismo equipo, gestión de servicios systemd local