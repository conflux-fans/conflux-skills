---
name: conflux-scan-rpc
description: Read-only Conflux eSpace queries — transactions, receipts, balances, contract state via RPC and ConfluxScan API. Use when analyzing tx failure/stuck, checking balances, or inspecting chain state. No private keys or sending txs.
metadata: {"requires":{"anyBins":["cast","curl"]}}
---

# Read-Only Conflux eSpace Queries

Help the user inspect Conflux eSpace state and analyze transactions (e.g. why a tx failed or is stuck). **Read-only:** no wallets, no signing, no sending. Prefer `cast` when on PATH; otherwise use `curl` with JSON-RPC.

## Safety

**READ-ONLY.** No private keys, no transaction signing. Safe for analyzing tx failures and chain state in-session.

## Networks (eSpace only)

| Network | RPC URL | Chain ID | ConfluxScan API |
|---------|---------|----------|-----------------|
| Mainnet | https://evm.confluxrpc.com | 1030 | https://evmapi.confluxscan.org |
| Testnet | https://evmtestnet.confluxrpc.com | 71 | https://evmapi-testnet.confluxscan.org |

Optional env: `export CONFLUX_ESPACE_RPC_URL="https://evmtestnet.confluxrpc.com"` (or mainnet). ConfluxScan API key can be used for higher rate limits (see [api-endpoints.md](api-endpoints.md)).

## Tool detection

```bash
command -v cast && echo "cast available" || echo "use curl"
```

## Query patterns (cast)

Use `--rpc-url` with eSpace RPC:

```bash
# Block number
cast block-number --rpc-url https://evmtestnet.confluxrpc.com

# Balance (CFX, in wei)
cast balance 0xADDRESS --rpc-url https://evmtestnet.confluxrpc.com
cast balance 0xADDRESS --ether --rpc-url https://evmtestnet.confluxrpc.com

# Transaction and receipt
cast tx 0xTXHASH --rpc-url https://evmtestnet.confluxrpc.com
cast receipt 0xTXHASH --rpc-url https://evmtestnet.confluxrpc.com

# Nonce (for stuck-tx analysis: compare confirmed vs pending)
cast nonce 0xADDRESS --rpc-url https://evmtestnet.confluxrpc.com
cast nonce 0xADDRESS --block pending --rpc-url https://evmtestnet.confluxrpc.com

# Contract code, gas price, chain ID
cast code 0xCONTRACT --rpc-url https://evmtestnet.confluxrpc.com
cast gas-price --rpc-url https://evmtestnet.confluxrpc.com
cast chain-id --rpc-url https://evmtestnet.confluxrpc.com

# ERC-20 token balance (raw; use --to-unit for human-readable)
cast call 0xTOKEN "balanceOf(address)(uint256)" 0xADDRESS --rpc-url https://evmtestnet.confluxrpc.com
# With decimals (e.g. 18): cast --to-unit $(cast call ...) 18
```

## Query patterns (curl JSON-RPC)

eSpace uses standard Ethereum JSON-RPC:

```bash
# Block number
curl -s -X POST https://evmtestnet.confluxrpc.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","id":1}'

# Balance
curl -s -X POST https://evmtestnet.confluxrpc.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xADDRESS","latest"],"id":1}'

# Transaction receipt
curl -s -X POST https://evmtestnet.confluxrpc.com \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["0xTXHASH"],"id":1}'
```

## Event logs

**Always use a narrow block range and contract address.** Full-range `eth_getLogs` / `cast logs` can hit rate limits or time out. Example: `cast logs 0xCONTRACT --from-block N --to-block N+1000 "Transfer(address,address,uint256)" --rpc-url <RPC>`.

## Transaction analysis (failure / stuck)

1. **Receipt:** `cast receipt 0xTXHASH --rpc-url <RPC>`. Check `status` (0 = fail, 1 = success). Conflux receipts may include `txExecErrorMsg` or similar for revert reason.
2. **Stuck / pending:** Compare `cast nonce ADDR` (latest) vs `cast nonce ADDR --block pending`. If pending > latest, txs are in mempool; earlier nonce must confirm or be replaced.
3. **Lifecycle:** Conflux eSpace: pending → mined → executed (~5 epochs) → confirmed (~50 epochs) → finalized. If receipt is null, tx may not be executed yet. See [api-endpoints.md](api-endpoints.md) for lifecycle doc link.

## ConfluxScan API (curl)

Etherscan-compatible REST API. Base: mainnet `https://evmapi.confluxscan.org`, testnet `https://evmapi-testnet.confluxscan.org`. Full endpoint list and params: [API swagger](https://evmapi.confluxscan.org/doc). Example (contract ABI):

```bash
# Get contract ABI (testnet; add ?apikey=KEY if needed)
curl -s "https://evmapi-testnet.confluxscan.org/api?module=contract&action=getabi&address=0xCONTRACT"
```

Copy-paste patterns and full endpoint table: [api-endpoints.md](api-endpoints.md). Rate limits and optional apikey: see ConfluxScan swagger.

## Related skills

- **conflux-docs** — official doc links and concepts.
- **conflux-dev** — deploy, verify, integrate apps.
