#!/usr/bin/env bash
set -euo pipefail

RPC_URL="${RPC_URL:-https://evm.confluxrpc.com}"
AIRDROP_ROLE="0x3a2f235c9daaf33349d300aadff2f15078a89df81bcfdd45ba11c8f816bddc6f"

usage() {
  cat <<'USAGE'
Usage:
  web3pay-ops.sh apps
  web3pay-ops.sh app-detail <app-alias-or-address>
  web3pay-ops.sh templates <app-alias-or-address>
  web3pay-ops.sh role-check <app-alias-or-address> <sender-address>
  web3pay-ops.sh validity <app-alias-or-address> <user-address>
  web3pay-ops.sh claim <app-alias-or-address>
  web3pay-ops.sh airdrop <app-alias-or-address> <template-id> <address=count>... [--dry-run|--confirm]
  web3pay-ops.sh airdrop-csv <app-alias-or-address> <template-id> <csv-path> [--dry-run|--confirm]

CSV format for airdrop:
  address,count
  0x1111111111111111111111111111111111111111,1

Wallet options are read at runtime:
  PRIVATE_KEY=0x...
  WALLET_MODE=interactive
  WALLET_MODE=browser
  ETH_KEYSTORE, ETH_KEYSTORE_ACCOUNT, ETH_PASSWORD, ETH_PASSWORD_FILE, ETH_FROM
  Set ETH_PASSWORD= to intentionally use an empty keystore password.

Optional:
  RPC_URL=https://evm.confluxrpc.com
USAGE
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

is_address() {
  [[ "$1" =~ ^0x[0-9a-fA-F]{40}$ ]]
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

resolve_app() {
  local key
  key="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$key" in
    confura-rpc|confura|rpc|0x33a9451ee070d750a077c93f71d2cfcd0180fa7d)
      APP_ALIAS="confura-rpc"
      APP_ADDR="0x33A9451ee070d750a077C93f71D2cFcD0180Fa7D"
      CARD_SHOP="0x8be2123e35CF39C6FAbB0d5Ed2dcc074c11F7407"
      TEMPLATE="0x62Ba85BDB737d2d814D44a26B14fee1De1817069"
      TRACKER="0x5154a68fe1fdAeB6A9B17Dee055BEF13B0401cA4"
      ;;
    confluxscan-api|confluxscan|scan|api|0x7f55828e334e63065b88055776db3a58734220ad)
      APP_ALIAS="confluxscan-api"
      APP_ADDR="0x7f55828e334e63065b88055776db3a58734220ad"
      CARD_SHOP="0xb816CBF6Fc07e8884FA3c3f6184C3395c95DB8B6"
      TEMPLATE="0x7C9e21a1D844DBe2b289dE39C93cb124336307c9"
      TRACKER="0x7F21892d29fa9b03b512e87EFAC0BcF7Ac42Ea63"
      ;;
    0x*)
      if ! is_address "$1"; then
        echo "Invalid app address: $1" >&2
        exit 1
      fi
      APP_ALIAS="custom"
      APP_ADDR="$1"
      CARD_SHOP="$(cast call "$APP_ADDR" 'cardShop()(address)' --rpc-url "$RPC_URL")"
      TEMPLATE="$(cast call "$CARD_SHOP" 'template()(address)' --rpc-url "$RPC_URL")"
      TRACKER="$(cast call "$CARD_SHOP" 'tracker()(address)' --rpc-url "$RPC_URL")"
      ;;
    *)
      echo "Unknown app alias or address: $1" >&2
      exit 1
      ;;
  esac
}

wallet_args() {
  WALLET_ARGS=()

  if [[ -n "${PRIVATE_KEY:-}" ]]; then
    WALLET_ARGS+=(--private-key "$PRIVATE_KEY")
  fi

  if [[ "${WALLET_MODE:-}" == "interactive" ]]; then
    WALLET_ARGS+=(--interactive)
  elif [[ "${WALLET_MODE:-}" == "browser" ]]; then
    WALLET_ARGS+=(--browser)
  fi

  if [[ -n "${ETH_FROM:-}" ]]; then
    WALLET_ARGS+=(--from "$ETH_FROM")
  fi
  if [[ -n "${ETH_KEYSTORE:-}" ]]; then
    WALLET_ARGS+=(--keystore "$ETH_KEYSTORE")
  fi
  if [[ -n "${ETH_KEYSTORE_ACCOUNT:-}" ]]; then
    WALLET_ARGS+=(--account "$ETH_KEYSTORE_ACCOUNT")
  fi
  if [[ "${ETH_PASSWORD+x}" == "x" ]]; then
    WALLET_ARGS+=(--password "$ETH_PASSWORD")
  fi
  if [[ -n "${ETH_PASSWORD_FILE:-}" ]]; then
    WALLET_ARGS+=(--password-file "$ETH_PASSWORD_FILE")
  fi
}

print_apps() {
  cat <<'APPS'
confura-rpc
  app:       0x33A9451ee070d750a077C93f71D2cFcD0180Fa7D
  cardShop:  0x8be2123e35CF39C6FAbB0d5Ed2dcc074c11F7407
  tracker:   0x5154a68fe1fdAeB6A9B17Dee055BEF13B0401cA4

confluxscan-api
  app:       0x7f55828e334e63065b88055776db3a58734220ad
  cardShop:  0xb816CBF6Fc07e8884FA3c3f6184C3395c95DB8B6
  tracker:   0x7F21892d29fa9b03b512e87EFAC0BcF7Ac42Ea63
APPS
}

template_summary() {
  case "$APP_ALIAS:$1" in
    confura-rpc:10001)
      echo "template: 10001 Standard/month, duration 30 days, tier 1. Public docs identify Standard as 100 QPS overall and 1,000,000 calls/day, with method-specific limits."
      ;;
    confura-rpc:10002)
      echo "template: 10002 Professional/month, duration 30 days, tier 2. Exact backend limits are not published in the referenced docs."
      ;;
    confura-rpc:10003)
      echo "template: 10003 Pro Plus/month, duration 30 days, tier 3. Exact backend limits are not published in the referenced docs."
      ;;
    confura-rpc:10004)
      echo "template: 10004 Standard/day, duration 1 day, tier 1. Same tier marker as Standard/month with shorter duration."
      ;;
    confluxscan-api:10001)
      echo "template: 10001 Standard/month, duration 30 days, Tier1 = Standard tier. Exact backend limits are not published in the referenced docs."
      ;;
    *)
      echo "template: $1. Unknown local meaning; verify with chain template list before issuing."
      ;;
  esac
}

validate_template() {
  case "$APP_ALIAS" in
    confura-rpc)
      case "$1" in
        10001|10002|10003|10004) ;;
        *)
          echo "Unknown Confura RPC template ID: $1. Run templates confura-rpc and update the skill reference before issuing it." >&2
          exit 1
          ;;
      esac
      ;;
    confluxscan-api)
      case "$1" in
        10001) ;;
        *)
          echo "Unknown ConfluxScan API template ID: $1. Run templates confluxscan-api and update the skill reference before issuing it." >&2
          exit 1
          ;;
      esac
      ;;
  esac
}

format_epoch() {
  local ts="$1"
  if [[ "$ts" == "0" ]]; then
    echo "never active"
    return
  fi
  if date -r "$ts" '+%Y-%m-%d %H:%M:%S %Z' >/dev/null 2>&1; then
    date -r "$ts" '+%Y-%m-%d %H:%M:%S %Z'
  else
    date -d "@$ts" '+%Y-%m-%d %H:%M:%S %Z'
  fi
}

parse_csv() {
  local csv="$1"
  RECEIVERS=()
  COUNTS=()
  local line_no=0

  while IFS=, read -r raw_addr raw_count _rest || [[ -n "${raw_addr:-}" ]]; do
    line_no=$((line_no + 1))
    local addr count
    addr="$(trim "${raw_addr:-}")"
    count="$(trim "${raw_count:-}")"

    if [[ -z "$addr" && -z "$count" ]]; then
      continue
    fi
    if [[ "$line_no" == "1" && "$(printf '%s' "$addr" | tr '[:upper:]' '[:lower:]')" == "address" ]]; then
      continue
    fi
    if ! is_address "$addr"; then
      echo "Invalid address at CSV line $line_no: $addr" >&2
      exit 1
    fi
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [[ "$count" == "0" ]]; then
      echo "Invalid count at CSV line $line_no: $count" >&2
      exit 1
    fi
    RECEIVERS+=("$addr")
    COUNTS+=("$count")
  done < "$csv"

  if [[ "${#RECEIVERS[@]}" == "0" ]]; then
    echo "No valid recipients found in CSV: $csv" >&2
    exit 1
  fi
}

parse_recipients() {
  RECEIVERS=()
  COUNTS=()
  local item addr count

  for item in "$@"; do
    addr="${item%%=*}"
    count="${item#*=}"
    addr="$(trim "$addr")"
    count="$(trim "$count")"

    if [[ "$item" != *"="* ]]; then
      echo "Invalid recipient argument: $item. Expected address=count" >&2
      exit 1
    fi
    if ! is_address "$addr"; then
      echo "Invalid recipient address: $addr" >&2
      exit 1
    fi
    if ! [[ "$count" =~ ^[0-9]+$ ]] || [[ "$count" == "0" ]]; then
      echo "Invalid recipient count for $addr: $count" >&2
      exit 1
    fi

    RECEIVERS+=("$addr")
    COUNTS+=("$count")
  done

  if [[ "${#RECEIVERS[@]}" == "0" ]]; then
    echo "No recipients provided. Use address=count arguments." >&2
    exit 1
  fi
}

join_array() {
  local IFS=,
  printf '[%s]' "$*"
}

base58_signature() {
  local sig="$1"
  node -e 'const alphabet="123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"; let hex=process.argv[1].replace(/^0x/,""); let bytes=hex.match(/../g).map(x=>parseInt(x,16)); let n=BigInt("0x"+hex); let out=""; while(n>0n){const r=Number(n%58n); out=alphabet[r]+out; n/=58n;} for (const b of bytes){ if (b===0) out=alphabet[0]+out; else break; } console.log(out || alphabet[0]);' "$sig"
}

main() {
  require_cmd cast

  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    apps)
      print_apps
      ;;
    app-detail)
      [[ "$#" == "1" ]] || { usage; exit 1; }
      resolve_app "$1"
      local vip_coin
      vip_coin="$(cast call "$APP_ADDR" 'getVipCoin()(address)' --rpc-url "$RPC_URL")"
      echo "app: $APP_ALIAS ($APP_ADDR)"
      echo "cardShop: $CARD_SHOP"
      echo "template: $TEMPLATE"
      echo "tracker: $TRACKER"
      echo "paymentType: $(cast call "$APP_ADDR" 'paymentType()(uint8)' --rpc-url "$RPC_URL")"
      echo "link: $(cast call "$APP_ADDR" 'link()(string)' --rpc-url "$RPC_URL")"
      echo "description: $(cast call "$APP_ADDR" 'description()(string)' --rpc-url "$RPC_URL")"
      echo "vipCoin: $vip_coin"
      echo "vipCoinName: $(cast call "$vip_coin" 'name()(string)' --rpc-url "$RPC_URL")"
      echo "vipCoinSymbol: $(cast call "$vip_coin" 'symbol()(string)' --rpc-url "$RPC_URL")"
      ;;
    templates)
      [[ "$#" == "1" ]] || { usage; exit 1; }
      resolve_app "$1"
      echo "app: $APP_ALIAS ($APP_ADDR)"
      echo "template: $TEMPLATE"
      cast call "$TEMPLATE" 'list(uint256,uint256)((uint256,string,string,uint256,uint256,uint256,(string[],string[]))[],uint256)' 0 20 --rpc-url "$RPC_URL"
      ;;
    role-check)
      [[ "$#" == "2" ]] || { usage; exit 1; }
      resolve_app "$1"
      local sender="$2"
      is_address "$sender" || { echo "Invalid sender address: $sender" >&2; exit 1; }
      echo "app: $APP_ALIAS ($APP_ADDR)"
      cast call "$APP_ADDR" 'hasRole(bytes32,address)(bool)' "$AIRDROP_ROLE" "$sender" --rpc-url "$RPC_URL"
      ;;
    validity)
      [[ "$#" == "2" ]] || { usage; exit 1; }
      resolve_app "$1"
      local user="$2"
      is_address "$user" || { echo "Invalid user address: $user" >&2; exit 1; }
      local raw expire now status
      raw="$(cast call "$TRACKER" 'getVipInfo(address)((uint256,(string[],string[]),string))' "$user" --rpc-url "$RPC_URL")"
      expire="$(printf '%s' "$raw" | sed -E 's/^\(([0-9]+).*/\1/')"
      now="$(date +%s)"
      if [[ "$expire" == "0" ]]; then
        status="inactive"
      elif (( expire > now )); then
        status="active"
      else
        status="expired"
      fi
      echo "app: $APP_ALIAS ($APP_ADDR)"
      echo "user: $user"
      echo "tracker: $TRACKER"
      echo "status: $status"
      echo "expireAt: $expire"
      echo "expireAtLocal: $(format_epoch "$expire")"
      echo "raw: $raw"
      ;;
    claim)
      [[ "$#" == "1" ]] || { usage; exit 1; }
      require_cmd node
      resolve_app "$1"
      wallet_args
      local message sig
      message="{\"domain\":\"web3pay\",\"contract\":\"$APP_ADDR\"}"
      if ((${#WALLET_ARGS[@]} > 0)); then
        sig="$(cast wallet sign "$message" "${WALLET_ARGS[@]}")"
      else
        sig="$(cast wallet sign "$message")"
      fi
      echo "app: $APP_ALIAS ($APP_ADDR)"
      echo "message: $message"
      echo "apiKey: $(base58_signature "$sig")"
      ;;
    airdrop|airdrop-csv)
      [[ "$#" -ge "3" ]] || { usage; exit 1; }
      resolve_app "$1"
      local template_id="$2"
      shift 2
      local dry_run=""
      local confirmed=""
      if [[ "${!#:-}" == "--dry-run" || "${!#:-}" == "--confirm" ]]; then
        if [[ "${!#:-}" == "--dry-run" ]]; then
          dry_run="--dry-run"
        else
          confirmed="--confirm"
        fi
        set -- "${@:1:$(($# - 1))}"
      fi
      [[ "$template_id" =~ ^[0-9]+$ ]] || { echo "Invalid template ID: $template_id" >&2; exit 1; }
      validate_template "$template_id"
      if [[ "$cmd" == "airdrop-csv" ]]; then
        [[ "$#" == "1" ]] || { usage; exit 1; }
        local csv="$1"
        [[ -f "$csv" ]] || { echo "CSV not found: $csv" >&2; exit 1; }
        parse_csv "$csv"
      else
        parse_recipients "$@"
      fi
      local receiver_arg count_arg
      receiver_arg="$(join_array "${RECEIVERS[@]}")"
      count_arg="$(join_array "${COUNTS[@]}")"
      wallet_args
      local send_cmd=(cast send "$CARD_SHOP" 'giveCardBatch(address[],uint256[],uint256)' "$receiver_arg" "$count_arg" "$template_id" --rpc-url "$RPC_URL")
      if ((${#WALLET_ARGS[@]} > 0)); then
        send_cmd+=("${WALLET_ARGS[@]}")
      fi
      echo "app: $APP_ALIAS ($APP_ADDR)"
      echo "cardShop: $CARD_SHOP"
      template_summary "$template_id"
      echo "recipientCount: ${#RECEIVERS[@]}"
      echo "receivers: $receiver_arg"
      echo "counts: $count_arg"
      if [[ "$dry_run" == "--dry-run" ]]; then
        local display_cmd=(cast send "$CARD_SHOP" 'giveCardBatch(address[],uint256[],uint256)' "$receiver_arg" "$count_arg" "$template_id" --rpc-url "$RPC_URL")
        if [[ -n "${PRIVATE_KEY:-}" ]]; then
          display_cmd+=(--private-key '<redacted>')
        fi
        if [[ "${WALLET_MODE:-}" == "interactive" ]]; then
          display_cmd+=(--interactive)
        elif [[ "${WALLET_MODE:-}" == "browser" ]]; then
          display_cmd+=(--browser)
        fi
        if [[ -n "${ETH_FROM:-}" ]]; then
          display_cmd+=(--from "$ETH_FROM")
        fi
        if [[ -n "${ETH_KEYSTORE:-}" ]]; then
          display_cmd+=(--keystore "$ETH_KEYSTORE")
        fi
        if [[ -n "${ETH_KEYSTORE_ACCOUNT:-}" ]]; then
          display_cmd+=(--account "$ETH_KEYSTORE_ACCOUNT")
        fi
        if [[ "${ETH_PASSWORD+x}" == "x" ]]; then
          display_cmd+=(--password '<redacted>')
        fi
        if [[ -n "${ETH_PASSWORD_FILE:-}" ]]; then
          display_cmd+=(--password-file "$ETH_PASSWORD_FILE")
        fi
        printf 'command:'
        printf ' %q' "${display_cmd[@]}"
        printf '\n'
      else
        if [[ "$confirmed" != "--confirm" ]]; then
          echo "Refusing to send without --confirm. Run with --dry-run first, confirm app/template/recipients/counts with the user, then add --confirm." >&2
          exit 1
        fi
        "${send_cmd[@]}"
      fi
      ;;
    ""|-h|--help|help)
      usage
      ;;
    *)
      echo "Unknown command: $cmd" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
