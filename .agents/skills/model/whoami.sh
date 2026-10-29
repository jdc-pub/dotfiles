#!/usr/bin/env bash
# whoami.sh — report the model this goose session is running as.
#
# stdout: "<Harness>:<model>"          (e.g. Goose:glm-5.3-flash)
# stderr: provenance, only with -v
# exit:   0 resolved · 1 unresolved · 2 not in a goose session
#
# Attribution follows the SESSION, not the process: AGENT_SESSION_ID names the
# session and goose's session record holds that session's model. This prefers
# the id the provider BILLED (usage_ledger), then the id the session REQUESTED
# (model_config_json.model_name). It never falls back to the configured default.
set -euo pipefail

verbose=0
if [[ "${1:-}" == "-v" ]]; then verbose=1; fi

log() { if (( verbose )); then printf 'whoami: %s\n' "$*" >&2; fi; return 0; }
die() { local code=$1; shift; printf 'whoami: %s\n' "$*" >&2; exit "$code"; }

# --- harness / session -------------------------------------------------------
session_id="${AGENT_SESSION_ID:-}"
if [[ -z "$session_id" ]]; then
  die 2 "not in a goose session (AGENT_SESSION_ID unset)"
fi
harness="goose"

# --- locate the session db ---------------------------------------------------
if [[ -n "${GOOSE_SESSIONS_DB:-}" ]]; then
  db="$GOOSE_SESSIONS_DB"
elif [[ -n "${GOOSE_PATH_ROOT:-}" ]]; then
  db="$GOOSE_PATH_ROOT/sessions/sessions.db"
else
  db="${XDG_DATA_HOME:-$HOME/.local/share}/goose/sessions/sessions.db"
fi

command -v sqlite3 >/dev/null 2>&1 || die 1 "sqlite3 not found on PATH"
[[ -f "$db" ]] || die 1 "session db not found: $db"

sid="${session_id//\'/\'\'}"   # escape for the SQL literal

exists=$(sqlite3 "$db" "SELECT 1 FROM sessions WHERE id='$sid' LIMIT 1;" || true)
[[ "$exists" == "1" ]] || die 1 "no session record for $session_id in $db"

# --- resolve the model -------------------------------------------------------
# 1) billed: latest non-empty model in the usage ledger
billed=$(sqlite3 "$db" \
  "SELECT model FROM usage_ledger
    WHERE session_id='$sid' AND model IS NOT NULL AND model<>''
    ORDER BY id DESC LIMIT 1;" || true)

# 2) requested: model_name from the session's model config (no JSON1 dependency)
requested=$(sqlite3 "$db" \
  "SELECT COALESCE(model_config_json,'') FROM sessions WHERE id='$sid' LIMIT 1;" \
  | sed -n 's/.*"model_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

if [[ -n "$billed" ]]; then
  model="$billed"; origin="usage_ledger (billed)"
elif [[ -n "$requested" ]]; then
  model="$requested"; origin="model_config_json (requested)"
else
  die 1 "session $session_id has no recorded model"
fi

# --- present -----------------------------------------------------------------
# remove one provider/vendor prefix (z-ai/glm-5.3-flash -> glm-5.3-flash)
model="${model#*/}"
# title-case the harness
harness="$(printf '%s' "${harness:0:1}" | tr '[:lower:]' '[:upper:]')${harness:1}"

log "session=$session_id db=$db"
log "source=$origin"
printf '%s:%s\n' "$harness" "$model"
