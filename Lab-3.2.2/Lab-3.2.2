#!/usr/bin/env bash
# ============================================================================
#  Lab-3.2.2-setup-workflow-slack.sh
#  CUY5132 - Comunicaciones Unificadas - DUOC UC
#
#  Crea automáticamente en n8n el workflow:
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

N8N_URL="https://n8nkito.duckdns.org"

banner() {
  echo -e "${C_INFO}"
  echo "============================================================"
  echo "   CUY5132 · Lab 3.2.2 — Slack + AI Agent (OpenRouter)"
  echo "============================================================"
  echo -e "${C_RESET}"
  echo -e "  Este script crea el workflow completo en n8n:"
  echo -e "  ${C_DIM}Slack Trigger → Anti-Bucle → AI Agent → Respuesta Slack${C_RESET}"
  echo
}

# ----------------------------------------------------------------------------
# PASO 1 — API Key de n8n
# ----------------------------------------------------------------------------
get_api_key() {
  echo -e "${C_WARN}━━━ PASO 1 de 5: API Key de n8n ━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo -e "  1. Abre en tu navegador: ${C_INFO}${N8N_URL}${C_RESET}"
  echo -e "  2. Ve a ${C_INFO}Settings${C_RESET} (menú izquierdo, abajo del todo)"
  echo -e "  3. Haz clic en ${C_INFO}n8n API${C_RESET}"
  echo -e "  4. Haz clic en ${C_INFO}Create an API key${C_RESET} y cópiala"
  echo
  read -rp "  Pega aquí tu API Key de n8n: " N8N_API_KEY
  [[ -n "${N8N_API_KEY}" ]] || die "La API Key no puede estar vacía."

  info "Verificando API Key..."
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "${N8N_URL}/api/v1/workflows")
  [[ "${HTTP}" == "200" ]] || die "API Key inválida o n8n no responde (HTTP ${HTTP})."
  ok "API Key válida."
  echo
}

# ----------------------------------------------------------------------------
# PASO 2 — Credencial de Slack
# ----------------------------------------------------------------------------
get_slack_credential() {
  echo -e "${C_WARN}━━━ PASO 2 de 5: Credencial de Slack ━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo -e "  Buscando credenciales en n8n..."

  CREDS_JSON=$(curl -s \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "${N8N_URL}/api/v1/credentials")

  # Mostrar credenciales disponibles
  echo "${CREDS_JSON}" | python3 -c "
import json, sys
data = json.load(sys.stdin).get('data', [])
if not data:
    print('  (No hay credenciales aún — créalas primero en n8n)')
else:
    print('  Credenciales encontradas:')
    for c in data:
        print(f\"    ID: {c['id']}  |  {c['name']}  |  tipo: {c['type']}\")
" 2>/dev/null

  echo
  echo -e "  ${C_DIM}Si no ves ninguna credencial de Slack, créala primero:${C_RESET}"
  echo -e "  ${C_DIM}n8n → Settings → Credentials → Add credential → Slack${C_RESET}"
  echo
  read -rp "  ID de la credencial de Slack: " SLACK_CRED_ID
  [[ -n "${SLACK_CRED_ID}" ]] || die "El ID no puede estar vacío."

  # Obtener nombre real de la credencial
  SLACK_CRED_NAME=$(echo "${CREDS_JSON}" | python3 -c "
import json, sys
data = json.load(sys.stdin).get('data', [])
match = next((c for c in data if c['id'] == '${SLACK_CRED_ID}'), None)
print(match['name'] if match else 'Slack account')
" 2>/dev/null || echo "Slack account")

  ok "Credencial Slack: ${SLACK_CRED_NAME} (ID: ${SLACK_CRED_ID})"
  echo
}

# ----------------------------------------------------------------------------
# PASO 3 — Canal de Slack
# ----------------------------------------------------------------------------
get_slack_channel() {
  echo -e "${C_WARN}━━━ PASO 3 de 5: Canal de Slack ━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
  echo -e "  El ID del canal empieza con ${C_INFO}C${C_RESET} (ej: ${C_DIM}C0B8J56KF0T${C_RESET})"
  echo -e "  ${C_DIM}Cómo encontrarlo: abre Slack en el navegador y mira la URL${C_RESET}"
  echo -e "  ${C_DIM}  https://app.slack.com/client/TXXXXXXX/${C_INFO}C0B8J56KF0T${C_DIM} ← ese es el ID${C_RESET}"
  echo
  read -rp "  ID del canal de Slack: " SLACK_CHANNEL_ID
  [[ -n "${SLACK_CHANNEL_ID}" ]] || die "El ID del canal no puede estar vacío."
  ok "Canal: ${SLACK_CHANNEL_ID}"
  echo
}

# ----------------------------------------------------------------------------
# PASO 4 — Credencial de OpenRouter
# ----------------------------------------------------------------------------
get_openrouter_credential() {
  echo -e "${C_WARN}━━━ PASO 4 de 5: Credencial de OpenRouter ━━━━━━━━━━━━━━━━━━${C_RESET}"

  # Filtrar credenciales de OpenRouter del listado previo
  echo "${CREDS_JSON}" | python3 -c "
import json, sys
data = json.load(sys.stdin).get('data', [])
matches = [c for c in data if 'openrouter' in c.get('type','').lower() or 'openrouter' in c.get('name','').lower()]
if matches:
    print('  Credenciales de OpenRouter encontradas:')
    for c in matches:
        print(f\"    ID: {c['id']}  |  {c['name']}\")
else:
    print('  No se encontró credencial de OpenRouter.')
    print('  Créala en: n8n → Settings → Credentials → Add credential → OpenRouter')
" 2>/dev/null

  echo
  read -rp "  ID de la credencial de OpenRouter: " OPENROUTER_CRED_ID
  [[ -n "${OPENROUTER_CRED_ID}" ]] || die "El ID no puede estar vacío."

  OPENROUTER_CRED_NAME=$(echo "${CREDS_JSON}" | python3 -c "
import json, sys
data = json.load(sys.stdin).get('data', [])
match = next((c for c in data if c['id'] == '${OPENROUTER_CRED_ID}'), None)
print(match['name'] if match else 'OpenRouter account')
" 2>/dev/null || echo "OpenRouter account")

  ok "Credencial OpenRouter: ${OPENROUTER_CRED_NAME} (ID: ${OPENROUTER_CRED_ID})"
  echo
}

# ----------------------------------------------------------------------------
# PASO 5 — Modelo y System Prompt
# ----------------------------------------------------------------------------
get_model_and_prompt() {
  echo -e "${C_WARN}━━━ PASO 5 de 5: Modelo y personalidad de la IA ━━━━━━━━━━━━${C_RESET}"
  echo -e "  Modelos gratuitos disponibles en OpenRouter:"
  echo -e "    ${C_INFO}1)${C_RESET} deepseek/deepseek-chat-v3-0324:free   (recomendado)"
  echo -e "    ${C_INFO}2)${C_RESET} google/gemma-3-27b-it:free"
  echo -e "    ${C_INFO}3)${C_RESET} mistralai/mistral-7b-instruct:free"
  echo -e "    ${C_INFO}4)${C_RESET} Escribir otro modelo manualmente"
  echo
  read -rp "  Elige modelo [1/2/3/4]: " MODEL_CHOICE
  case "${MODEL_CHOICE}" in
    1|"") MODEL="deepseek/deepseek-chat-v3-0324:free" ;;
    2)    MODEL="google/gemma-3-27b-it:free" ;;
    3)    MODEL="mistralai/mistral-7b-instruct:free" ;;
    4)    read -rp "  Escribe el modelo exacto: " MODEL ;;
    *)    MODEL="deepseek/deepseek-chat-v3-0324:free" ;;
  esac
  ok "Modelo: ${MODEL}"

  echo
  echo -e "  System prompt (define la personalidad de la IA):"
  echo -e "  ${C_DIM}Presiona Enter para usar el prompt por defecto${C_RESET}"
  read -rp "  System prompt: " SYSTEM_PROMPT
  if [[ -z "${SYSTEM_PROMPT}" ]]; then
    SYSTEM_PROMPT="Eres un asistente virtual útil y amigable. Responde siempre en español de forma clara y concisa."
  fi
  ok "System prompt configurado."
  echo
}

# ----------------------------------------------------------------------------
# Crear el workflow via API de n8n
# ----------------------------------------------------------------------------
create_workflow() {
  info "Creando workflow en n8n..."

  # Escapar el system prompt para JSON
  SYSTEM_PROMPT_ESCAPED=$(echo "${SYSTEM_PROMPT}" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read().strip()))" | sed 's/^"//;s/"$//')

  WORKFLOW_JSON=$(python3 -c "
import json

workflow = {
  'name': 'texto en slack',
  'nodes': [
    {
      'parameters': {
        'triggerOn': 'anyEvent',
        'watchWholeWorkspace': True,
        'downloadFiles': True
      },
      'id': 'node-slack-trigger',
      'name': 'Slack Trigger',
      'type': 'n8n-nodes-base.slackTrigger',
      'typeVersion': 1,
      'position': [240, 300],
      'credentials': {
        'slackApi': {
          'id': '${SLACK_CRED_ID}',
          'name': '${SLACK_CRED_NAME}'
        }
      }
    },
    {
      'parameters': {
        'conditions': {
          'options': {
            'caseSensitive': True,
            'leftValue': '',
            'typeValidation': 'strict'
          },
          'conditions': [
            {
              'id': 'cond-bot-filter',
              'leftValue': '={{ \$json.bot_id }}',
              'rightValue': '',
              'operator': {
                'type': 'string',
                'operation': 'empty',
                'singleValue': True
              }
            }
          ],
          'combinator': 'and'
        }
      },
      'id': 'node-if-filter',
      'name': 'Filtro Anti-Bucle',
      'type': 'n8n-nodes-base.if',
      'typeVersion': 2,
      'position': [460, 300]
    },
    {
      'parameters': {
        'promptType': 'define',
        'text': '={{ \$json.text }}',
        'options': {
          'systemMessage': '${SYSTEM_PROMPT_ESCAPED}'
        }
      },
      'id': 'node-ai-agent',
      'name': 'AI Agent',
      'type': '@n8n/n8n-nodes-langchain.agent',
      'typeVersion': 1.7,
      'position': [680, 180]
    },
    {
      'parameters': {
        'model': '${MODEL}',
        'options': {}
      },
      'id': 'node-openrouter',
      'name': 'OpenRouter Chat Model',
      'type': '@n8n/n8n-nodes-langchain.lmChatOpenRouter',
      'typeVersion': 1,
      'position': [680, 400],
      'credentials': {
        'openRouterApi': {
          'id': '${OPENROUTER_CRED_ID}',
          'name': '${OPENROUTER_CRED_NAME}'
        }
      }
    },
    {
      'parameters': {
        'select': 'channel',
        'channelId': {
          'value': '${SLACK_CHANNEL_ID}',
          '__rl': True,
          'mode': 'id'
        },
        'text': '={{ \$json.output }}',
        'otherOptions': {}
      },
      'id': 'node-slack-send',
      'name': 'Enviar respuesta a Slack',
      'type': 'n8n-nodes-base.slack',
      'typeVersion': 2.3,
      'position': [900, 180],
      'credentials': {
        'slackApi': {
          'id': '${SLACK_CRED_ID}',
          'name': '${SLACK_CRED_NAME}'
        }
      }
    }
  ],
  'connections': {
    'Slack Trigger': {
      'main': [[{'node': 'Filtro Anti-Bucle', 'type': 'main', 'index': 0}]]
    },
    'Filtro Anti-Bucle': {
      'main': [
        [{'node': 'AI Agent', 'type': 'main', 'index': 0}],
        []
      ]
    },
    'AI Agent': {
      'main': [[{'node': 'Enviar respuesta a Slack', 'type': 'main', 'index': 0}]]
    },
    'OpenRouter Chat Model': {
      'ai_languageModel': [[{'node': 'AI Agent', 'type': 'ai_languageModel', 'index': 0}]]
    }
  },
  'settings': {'executionOrder': 'v1'},
  'active': False
}

print(json.dumps(workflow))
")

  RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    -H "Content-Type: application/json" \
    -d "${WORKFLOW_JSON}" \
    "${N8N_URL}/api/v1/workflows")

  HTTP_CODE=$(echo "${RESPONSE}" | tail -n1)
  BODY=$(echo "${RESPONSE}" | head -n-1)

  if [[ "${HTTP_CODE}" == "200" ]] || [[ "${HTTP_CODE}" == "201" ]]; then
    WORKFLOW_ID=$(echo "${BODY}" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id','?'))" 2>/dev/null || echo "?")
    ok "Workflow creado con ID: ${WORKFLOW_ID}"

    # Activar el workflow
    info "Publicando workflow..."
    ACT_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      -X PATCH \
      -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
      -H "Content-Type: application/json" \
      -d '{"active": true}' \
      "${N8N_URL}/api/v1/workflows/${WORKFLOW_ID}")

    if [[ "${ACT_CODE}" == "200" ]]; then
      ok "Workflow publicado y activo."
    else
      warn "Workflow creado pero no se pudo publicar automáticamente."
      warn "Ábrelo en n8n y haz clic en Publish manualmente."
    fi
  else
    echo -e "${C_ERR}Error al crear el workflow (HTTP ${HTTP_CODE}):${C_RESET}"
    echo "${BODY}" | python3 -m json.tool 2>/dev/null || echo "${BODY}"
    die "Revisa los datos e intenta de nuevo."
  fi
}

# ----------------------------------------------------------------------------
# Resumen final
# ----------------------------------------------------------------------------
summary() {
  echo
  echo -e "${C_OK}============================================================${C_RESET}"
  echo -e "${C_OK}  ¡Lab 3.2.2 configurado exitosamente!${C_RESET}"
  echo -e "${C_OK}============================================================${C_RESET}"
  echo
  echo -e "  Workflow  : ${C_INFO}texto en slack${C_RESET}"
  echo -e "  Canal     : ${C_INFO}${SLACK_CHANNEL_ID}${C_RESET}"
  echo -e "  Modelo IA : ${C_INFO}${MODEL}${C_RESET}"
  echo -e "  Anti-bucle: ${C_OK}✓ activado${C_RESET}"
  echo
  echo -e "  ${C_WARN}Para verificar:${C_RESET}"
  echo -e "  1. Abre Slack y escribe un mensaje en el canal"
  echo -e "  2. El bot debería responder en 10-30 segundos"
  echo -e "  3. Si no responde, revisa Executions en n8n:"
  echo -e "     ${C_DIM}${N8N_URL}/home/executions${C_RESET}"
  echo
}

# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------
main() {
  banner
  get_api_key
  get_slack_credential
  get_slack_channel
  get_openrouter_credential
  get_model_and_prompt
  create_workflow
  summary
}

main "$@"
