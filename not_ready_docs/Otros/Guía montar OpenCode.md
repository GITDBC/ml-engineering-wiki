---
type: concept
title: "Guía montar OpenCode"
created: 2026-05-19
updated: 2026-08-17
tags:
    - opencode
    - ollama
    - tailscale
    - llm-local
    - gpu
status: developing
related:
    - "[[Bitácora: setup Ollama local]]"
    - "[[Lista de tareas]]"
sources: []
---

# Guía: montar OpenCode + modelo local en un servidor con RTX 3060 Laptop 6GB

Objetivo:

```text
[Portátil cliente]
OpenCode / terminal
        │
        │ Red local o Tailscale
        ▼
[Servidor en casa]
RTX 3060 Laptop 6GB
Ollama
Modelo local
```

Con esto podrás usar un terminal tipo Claude Code/OpenCode, pero ejecutando el modelo en tu servidor doméstico.

---

# 1. Qué puedes esperar con 6GB VRAM

Con una 3060 Laptop 6GB:

## Va bien

* modelos 7B cuantizados
* coding ligero/medio
* autocompletado
* terminal agents
* refactors pequeños
* RAG simple

## Va regular

* modelos 14B
* contexto enorme
* agentes complejos multi-tool

## No recomendable

* 32B
* reasoning gigante
* múltiples agentes simultáneos

---

# 2. Mejor stack para tu caso

| Componente       | Recomendación                                                      |
| ---------------- | ----------------------------------------------------------------- |
| Runtime          | [Ollama](https://ollama.com)                                      |
| Cliente terminal | [OpenCode](https://github.com/sst/opencode)                       |
| Acceso remoto    | [Tailscale](https://tailscale.com)                                |
| SO servidor      | Ubuntu 24.04                                                      |
| Modelo coding    | Qwen2.5-Coder 7B Q4                                               |

> [!contradiction] Contradicción con la instalación real
> La guía recomienda **Ubuntu 24.04**, pero el montaje real de esta configuración se hizo sobre **Debian**. Ver [[Bitácora: setup Ollama local]]. Los pasos son los mismos en ambos SO.

---

# 3. Instalar Ubuntu en el servidor

Idealmente:

* Ubuntu Server 24.04
* Drivers NVIDIA instalados
* CUDA funcionando

Comprobar GPU:

```bash
nvidia-smi
```

Debes ver la RTX 3060.

---

# 4. Instalar Ollama

En el servidor:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Verifica:

```bash
ollama --version
```

---

# 5. Configurar Ollama para aceptar conexiones de red

Por defecto Ollama escucha solo en localhost.

Necesitas exponerlo.

Edita:

```bash
sudo systemctl edit ollama
```

Añade:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

Luego:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

Comprueba:

```bash
ss -tulnp | grep 11434
```

Debe aparecer:

```text
0.0.0.0:11434
```

---

# 6. Descargar un modelo adecuado

Con 6GB VRAM recomiendo:

## Mejor equilibrio

```bash
ollama run qwen2.5-coder:7b
```

Muy bueno para:

* Python
* JS/TS
* Bash
* debugging
* terminal workflows

---

## Alternativas

### Más rápido

```bash
ollama run qwen2.5-coder:3b
```

### Más inteligente pero más pesado

```bash
ollama run deepseek-coder-v2:16b
```

(irá lento y parcialmente en RAM)

---

# 7. Probar desde otro ordenador

Desde tu portátil:

```bash
curl http://IP_SERVIDOR:11434/api/tags
```

Debe devolver JSON.

Ejemplo:

```text
http://192.168.1.50:11434
```

---

# 8. Instalar OpenCode en el portátil

Instala Node.js primero.

Luego:

```bash
npm install -g opencode-ai
```

Repo oficial:

[OpenCode GitHub](https://github.com/sst/opencode)

---

# 9. Configurar OpenCode para usar Ollama remoto

Crea:

```bash
~/.config/opencode/config.json
```

Contenido:

```json
{
  "provider": {
    "ollama": {
      "baseUrl": "http://192.168.1.50:11434"
    }
  },
  "model": "qwen2.5-coder:7b"
}
```

Cambia la IP por la de tu servidor.

---

# 10. Usarlo

En cualquier proyecto:

```bash
opencode
```

Ahora:

* OpenCode corre en tu portátil
* el modelo corre en el servidor
* los tokens se transmiten por red local

---

# 11. Rendimiento esperado

Con RTX 3060 Laptop 6GB:

## Qwen2.5-Coder 7B Q4

Esperable:

| Métrica  | Valor  |
| -------- | ------ |
| Tokens/s | 15–30  |
| Latencia | Buena  |
| RAM      | 8–12GB |
| VRAM     | ~5GB   |

Perfectamente usable.

---

# 12. Configuración MUY recomendable

## Mantener modelo cargado

Edita:

```bash
/etc/systemd/system/ollama.service
```

o añade variable:

```ini
Environment="OLLAMA_KEEP_ALIVE=24h"
```

Así:

* no descarga el modelo
* respuestas más rápidas

---

# 13. Acceso desde fuera de casa

Instala:

* [Tailscale](https://tailscale.com)

En:

* servidor
* portátil

Entonces podrás usar:

```text
http://100.x.x.x:11434
```

desde cualquier sitio.

---

# 14. Seguridad IMPORTANTÍSIMA

NO abras directamente:

```text
11434
```

a internet.

Usa:

* Tailscale
* VPN
* reverse proxy con auth

Porque Ollama no trae seguridad fuerte por defecto.

---

# 15. Setup ideal para tu hardware

## Servidor

* Ubuntu Server
* Ollama
* Qwen2.5-Coder 7B
* Tailscale

## Cliente

* portátil ligero
* OpenCode
* VS Code opcional

---

# 16. Mejoras futuras

Cuando quieras más potencia:

| Upgrade         | Mejora           |
| --------------- | ---------------- |
| 12GB VRAM       | modelos 14B      |
| 24GB VRAM       | 32B cuantizados  |
| vLLM            | más throughput   |
| SSD NVMe rápido | carga más rápida |
| RAM 32GB+       | offloading mejor |

---

# 17. Comandos finales resumidos

## Servidor

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

```bash
ollama run qwen2.5-coder:7b
```

---

## Cliente

```bash
npm install -g opencode-ai
```

---

## Config

```json
{
  "provider": {
    "ollama": {
      "baseUrl": "http://IP_SERVIDOR:11434"
    }
  },
  "model": "qwen2.5-coder:7b"
}
```

---

# 18. Resultado final

Terminas con algo parecido a esto:

```text
Tu portátil
↓
OpenCode
↓
LAN/Tailscale
↓
Servidor RTX 3060
↓
Ollama
↓
LLM local
```

Muy parecido conceptualmente a:

* Claude Code
* Cursor remote
* Copilot backend

pero completamente local y privado.

## Conexiones

- [[Bitácora: setup Ollama local]] — qué falló en el montaje real y cómo quedó el sistema
- [[Lista de tareas]] — la ML Wiki plantea una sección dedicada al desarrollo con IA (MCP, agentes, skills, opencode)