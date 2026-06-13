#!/usr/bin/env bash
# ============================================================================
#  Lab-3.2.2-setup-workflow-slack.sh
#  CUY5132 - Comunicaciones Unificadas - DUOC UC
#
#  Genera un archivo workflow.json listo para importar en n8n con:
#  Slack Trigger → Filtro Anti-Bucle → AI Agent (OpenRouter) → Slack
#
#  Uso:
#    bash Lab-3.2.2-setup-workflow-slack.sh
# ============================================================================

set -euo pipefail

C_RESET='\033[0m'; C_INFO='\033[1;34m'; C_OK='\033[1;32m'
C_WARN='\033[1;33m'; C_ERR='\033[1;31m'; C_DIM='\033[2m'

info() { echo -e "${C_INFO}[*]${C_RESET} $*"; }
ok()   { echo -e "${C_OK}[✓]${C_RESET} $*"; }
warn() { echo -e "${C_WARN}[!]${C_RESET} $*"; }
die()  { echo -e "${C_ERR}[x]${C_RESET} $*" >&2; exit 1; }

OUTPUT_FILE="workflow-slack.json"

banner() {
  echo -e "${C_INFO}"
  echo "============================================================"
  echo "   CUY5132 · Lab 3.2.2 — Generador de Workflow Slack + IA"
  echo "============================================================"
  echo -e "${C_RESET}"
  echo -e "  Este script genera un archivo JSON con tu workflow listo"
  echo -e "  para importar directamente en n8n (sin API)."
  echo
}

# ----------------------------------------------------------------------------
get_slack_channel() {
  echo -e "${C_WARN}━━━ PASO 1 de 4: ID del canal de Slack ━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo -e "  El ID del canal empieza con ${C_INFO}C${C_RESET} (ej: ${C_DIM}C0B8J56KF0T${C_RESET})"
  echo
  echo -e "  ${C_INFO}Cómo encontrarlo:${C_RESET}"
  echo -e "    A) Abre Slack en el navegador, entra al canal y mira la URL"
  echo -e "    B) En Slack app → clic derecho en el canal → Ver detalles"
  echo
  read -rp "  Pega aquí el ID del canal: " SLACK_CHANNEL_ID
  [[ -n "${SLACK_CHANNEL_ID}" ]] || die "El ID del canal no puede estar vacío."
  ok "Canal: ${SLACK_CHANNEL_ID}"
  echo
}

# ----------------------------------------------------------------------------
get_model() {
  echo -e "${C_WARN}━━━ PASO 2 de 4: Modelo de IA en OpenRouter ━━━━━━━━━━━━━━━━${C_RESET}"
  echo -e "  Modelos gratuitos:"
  echo -e "    ${C_INFO}1)${C_RESET} deepseek/deepseek-chat-v3-0324:free  ${C_DIM}(recomendado)${C_RESET}"
  echo -e "    ${C_INFO}2)${C_RESET} google/gemma-3-27b-it:free"
  echo -e "    ${C_INFO}3)${C_RESET} mistralai/mistral-7b-instruct:free"
  echo -e "    ${C_INFO}4)${C_RESET} Otro (manual)"
  echo
  read -rp "  Elige [1/2/3/4]: " MODEL_CHOICE
  case "${MODEL_CHOICE}" in
    1|"") MODEL="deepseek/deepseek-chat-v3-0324:free" ;;
    2)    MODEL="google/gemma-3-27b-it:free" ;;
    3)    MODEL="mistralai/mistral-7b-instruct:free" ;;
    4)    read -rp "  Escribe el modelo exacto: " MODEL ;;
    *)    MODEL="deepseek/deepseek-chat-v3-0324:free" ;;
  esac
  ok "Modelo: ${MODEL}"
  echo
}

# ----------------------------------------------------------------------------
get_system_prompt() {
  echo -e "${C_WARN}━━━ PASO 3 de 4: System Prompt (personalidad de la IA) ━━━━━${C_RESET}"
  echo -e "  ${C_DIM}Enter para usar el prompt por defecto${C_RESET}"
  echo
  read -rp "  System prompt: " SYSTEM_PROMPT
  if [[ -z "${SYSTEM_PROMPT}" ]]; then
    SYSTEM_PROMPT="Eres un asistente virtual útil y amigable. Responde siempre en español de forma clara y concisa."
  fi
  ok "Personalidad configurada."
  echo
}

# ----------------------------------------------------------------------------
get_workflow_name() {
  echo -e "${C_WARN}━━━ PASO 4 de 4: Nombre del workflow ━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo -e "  ${C_DIM}Enter para usar 'texto en slack'${C_RESET}"
  echo
  read -rp "  Nombre: " WORKFLOW_NAME
  [[ -n "${WORKFLOW_NAME}" ]] || WORKFLOW_NAME="texto en slack"
  ok "Nombre: ${WORKFLOW_NAME}"
  echo
}

# ----------------------------------------------------------------------------
generate_json() {
  info "Generando archivo ${OUTPUT_FILE}..."

  # Exportar variables para que python las lea sin problemas de escape
  export SLACK_CHANNEL_ID MODEL SYSTEM_PROMPT WORKFLOW_NAME

  python3 - > "${OUTPUT_FILE}" <<'PYEOF'
import json, os

workflow = {
  "name": os.environ["WORKFLOW_NAME"],
  "nodes": [
    {
      "parameters": {
        "triggerOn": "anyEvent",
        "watchWholeWorkspace": True,
        "downloadFiles": True
      },
      "id": "node-slack-trigger",
      "name": "Slack Trigger",
      "type": "n8n-nodes-base.slackTrigger",
      "typeVersion": 1,
      "position": [240, 300]
    },
    {
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": True,
            "leftValue": "",
            "typeValidation": "strict"
          },
          "conditions": [
            {
              "id": "cond-bot-filter",
              "leftValue": "={{ $json.bot_id }}",
              "rightValue": "",
              "operator": {
                "type": "string",
                "operation": "empty",
                "singleValue": True
              }
            }
          ],
          "combinator": "and"
        }
      },
      "id": "node-if-filter",
      "name": "Filtro Anti-Bucle",
      "type": "n8n-nodes-base.if",
      "typeVersion": 2,
      "position": [460, 300]
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "={{ $json.text }}",
        "options": {
          "systemMessage": os.environ["SYSTEM_PROMPT"]
        }
      },
      "id": "node-ai-agent",
      "name": "AI Agent",
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 1.7,
      "position": [680, 180]
    },
    {
      "parameters": {
        "model": os.environ["MODEL"],
        "options": {}
      },
      "id": "node-openrouter",
      "name": "OpenRouter Chat Model",
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenRouter",
      "typeVersion": 1,
      "position": [680, 400]
    },
    {
      "parameters": {
        "select": "channel",
        "channelId": {
          "value": os.environ["SLACK_CHANNEL_ID"],
          "__rl": True,
          "mode": "id"
        },
        "text": "={{ $json.output }}",
        "otherOptions": {}
      },
      "id": "node-slack-send",
      "name": "Enviar respuesta a Slack",
      "type": "n8n-nodes-base.slack",
      "typeVersion": 2.3,
      "position": [900, 180]
    }
  ],
  "connections": {
    "Slack Trigger": {
      "main": [[{"node": "Filtro Anti-Bucle", "type": "main", "index": 0}]]
    },
    "Filtro Anti-Bucle": {
      "main": [
        [{"node": "AI Agent", "type": "main", "index": 0}],
        []
      ]
    },
    "AI Agent": {
      "main": [[{"node": "Enviar respuesta a Slack", "type": "main", "index": 0}]]
    },
    "OpenRouter Chat Model": {
      "ai_languageModel": [[{"node": "AI Agent", "type": "ai_languageModel", "index": 0}]]
    }
  },
  "settings": {"executionOrder": "v1"},
  "pinData": {}
}

print(json.dumps(workflow, indent=2, ensure_ascii=False))
PYEOF

  ok "Archivo generado: $(pwd)/${OUTPUT_FILE}"
  echo
}

# ----------------------------------------------------------------------------
summary() {
  echo -e "${C_OK}============================================================${C_RESET}"
  echo -e "${C_OK}  ¡Archivo de workflow generado!${C_RESET}"
  echo -e "${C_OK}============================================================${C_RESET}"
  echo
  echo -e "  Archivo: ${C_INFO}$(pwd)/${OUTPUT_FILE}${C_RESET}"
  echo
  echo -e "  ${C_WARN}━━━ Cómo importar en n8n ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo
  echo -e "  ${C_INFO}1.${C_RESET} Muestra el contenido para copiarlo:"
  echo -e "     ${C_DIM}cat ${OUTPUT_FILE}${C_RESET}"
  echo
  echo -e "  ${C_INFO}2.${C_RESET} En n8n (https://n8nkito.duckdns.org):"
  echo -e "     • Ve a ${C_INFO}Workflows${C_RESET} → ${C_INFO}+ Add workflow${C_RESET} (crea uno vacío)"
  echo -e "     • Clic en los ${C_INFO}···${C_RESET} (arriba a la derecha del canvas)"
  echo -e "     • Selecciona ${C_INFO}Import from File${C_RESET} o ${C_INFO}Import from URL${C_RESET}"
  echo -e "     • Pega o sube el JSON"
  echo
  echo -e "  ${C_INFO}3.${C_RESET} Asigna las credenciales (clic en cada nodo):"
  echo -e "     • ${C_INFO}Slack Trigger${C_RESET}            → credencial Slack"
  echo -e "     • ${C_INFO}OpenRouter Chat Model${C_RESET}    → credencial OpenRouter"
  echo -e "     • ${C_INFO}Enviar respuesta a Slack${C_RESET} → credencial Slack"
  echo
  echo -e "  ${C_INFO}4.${C_RESET} Clic en ${C_INFO}Publish${C_RESET} (arriba a la derecha)"
  echo
  echo -e "  ${C_INFO}5.${C_RESET} Escribe un mensaje en Slack y verifica la respuesta de la IA"
  echo
  echo -e "  ${C_OK}Estructura:${C_RESET} Slack Trigger → Anti-Bucle → AI Agent → Slack"
  echo
}

main() {
  banner
  get_slack_channel
  get_model
  get_system_prompt
  get_workflow_name
  generate_json
  summary
}

main "$@"
