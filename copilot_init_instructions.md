copilot_init_instructions.md
markdown
Copiar
Editar
# 🧠 INSTRUCCIONES COPILOT — Landing Orbix IA

## 🎯 Objetivo:
Publicar esta landing page profesional en GitHub Pages desde este repositorio, bajo el dominio personalizado `sistemasorbix.com`.

## 🗂️ Archivos esperados:
- index.html → versión principal basada en `curriculum_orbix_actualizado.html`
- style.css (si se extrae CSS externo)
- CNAME → con contenido: `sistemasorbix.com`
- README.md → con descripción para SEO de Orbix AI Systems
- COPILOT_PROMPT.md → perfil IA y propósito del sitio

## 🔧 Tareas que debe ejecutar Copilot:

1. Crear el archivo `index.html` con el contenido de la landing actual (tomado de curriculum_orbix_actualizado.html).

2. Si el CSS está embebido, opcionalmente extraerlo a `style.css` y enlazarlo desde el HTML.

3. Crear el archivo `CNAME` con el contenido exacto:
sistemasorbix.com

yaml
Copiar
Editar

4. Crear `README.md` con la descripción breve:
```markdown
# Orbix AI Systems
Landing oficial de Orbix AI Systems: automatización inteligente, seguridad digital y validación financiera con GPT-4 y Odoo.
Crear COPILOT_PROMPT.md con:

markdown
Copiar
Editar
# Propósito del sitio
Este sitio representa la presencia profesional de Luis Enrique Mata y la plataforma Orbix AI Systems. Muestra capacidades en IA, validación bancaria, automatización, Odoo, seguridad y DevOps.

# Funciones esperadas
- Interfaz moderna y responsive
- Publicación automatizada vía GitHub Pages
- Dominio personalizado funcionando: sistemasorbix.com
Inicializar Git y conectar con el repositorio:

bash
Copiar
Editar
git init
git add .
git commit -m "Landing Orbix IA lista"
git branch -M main
git remote add origin git@github.com:yovoyTecSRL/sistemasorbix.com.git
git push -u origin main
Verificar que CNAME esté en el repositorio con el dominio correcto.

Activar GitHub Pages desde la UI:

Branch: main

Folder: /root

Confirmar que la landing esté accesible en:

👉 https://sistemasorbix.com

🚀 Siguiente paso:
📌 Abrí tu Codespace en el repo sistemasorbix.com y pegá este contenido en un archivo copilot_init_instructions.md.

🧠 Luego, en Copilot Chat escribí:

perl
Copiar
Editar
@copilot seguí las instrucciones de copilot_init_instructions.md y subí la landing

