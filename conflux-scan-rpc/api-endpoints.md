# ConfluxScan API and RPC reference

## ConfluxScan API

- **Mainnet:** https://evmapi.confluxscan.org
- **Testnet:** https://evmapi-testnet.confluxscan.org
- **Swagger (interactive):** https://evmapi.confluxscan.org/doc
- **OpenAPI spec (JSON):** https://evmapi.confluxscan.org/spec

Append `?module=...&action=...&...` to base URL. Optional `apikey` for higher limits (contact Conflux or Web3 Paywall).

### Endpoint table

| Use case        | module     | action        | Key params                  |
|-----------------|------------|---------------|-----------------------------|
| Contract ABI    | contract   | getabi        | address                     |
| Contract source | contract   | getsourcecode | address                     |
| Account txs      | account    | txlist        | address, page, offset, sort |
| Token transfers | account    | tokentx       | address, page, offset, sort  |
| Gas oracle      | (varies)   | Check swagger | ConfluxScan may use different module than Etherscan. |

### Curl examples (testnet base: https://evmapi-testnet.confluxscan.org)

```bash
# Contract ABI
curl -s "https://evmapi-testnet.confluxscan.org/api?module=contract&action=getabi&address=0xCONTRACT"

# Contract source
curl -s "https://evmapi-testnet.confluxscan.org/api?module=contract&action=getsourcecode&address=0xCONTRACT"

# Account tx list (latest 10)
curl -s "https://evmapi-testnet.confluxscan.org/api?module=account&action=txlist&address=0xADDRESS&page=1&offset=10&sort=desc"

# Token transfers
curl -s "https://evmapi-testnet.confluxscan.org/api?module=account&action=tokentx&address=0xADDRESS&page=1&offset=10&sort=desc"

# Gas oracle (if supported; confirm module/action in swagger)
# curl -s "https://evmapi-testnet.confluxscan.org/api?module=...&action=..."
```

Use mainnet base `https://evmapi.confluxscan.org` for mainnet. Add `&apikey=KEY` if you have a key.

## eSpace RPC methods (EVM)

Same as Ethereum. Common: `eth_blockNumber`, `eth_getBalance`, `eth_getTransactionByHash`, `eth_getTransactionReceipt`, `eth_getCode`, `eth_getTransactionCount` (nonce), `eth_gasPrice`, `eth_chainId`, `eth_call`, `eth_getLogs` (use narrow block ranges).

## Transaction lifecycle (Conflux)

eSpace txs: **Pending** → **Mined** (in block) → **Executed** (~5 epochs) → **Confirmed** (~50 epochs) → **Finalized** (PoS, ~4–6 min). Receipt may be null until executed. Official doc: https://doc.confluxnetwork.org/docs/core/core-space-basics/transactions/lifecycle (Core Space lifecycle is analogous; eSpace follows similar ordering.)

## Receipt fields for failure

- `status`: `0x0` = reverted, `0x1` = success.
- Conflux-specific: look for `txExecErrorMsg` or error message in receipt when available for revert reason.
