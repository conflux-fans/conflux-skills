# Confura Public RPC Usage Guide

This is the user-facing RPC guide for Confura. It focuses on how applications should call the service, not on how Confura is implemented internally.

## Pick the right space

| User need | Use | Method prefix | Address format |
|---|---|---|---|
| Native Conflux Core Space, sponsorship, staking, CIP-37 addresses | Core Space | `cfx_*` | `cfx:` / `cfxtest:` |
| MetaMask, ethers.js, viem, Foundry, Ethereum-compatible contracts | eSpace | `eth_*` | `0x...` |

Do not mix `cfx_*` methods with eSpace endpoints or `eth_*` methods with Core endpoints.

## Endpoint matrix

### Core Space

| Network | HTTP endpoint | WebSocket endpoint | Chain ID |
|---|---|---|---|
| Mainnet | `https://main.confluxrpc.com` | `wss://main.confluxrpc.com/ws` | `1029` / `0x405` |
| Mainnet China | `https://cfxmain-china.confluxrpc.com` | - | `1029` / `0x405` |
| Mainnet Global | `https://cfxmain-global.confluxrpc.com` | - | `1029` / `0x405` |
| Mainnet backup | `https://main.confluxrpc.org` | `wss://main.confluxrpc.org/ws` | `1029` / `0x405` |
| Testnet | `https://test.confluxrpc.com` | `wss://test.confluxrpc.com/ws` | `1` / `0x1` |
| Testnet alternate | `https://cfxtest.confluxrpc.com` | - | `1` / `0x1` |
| Testnet backup | `https://test.confluxrpc.org` | `wss://test.confluxrpc.org/ws` | `1` / `0x1` |

### eSpace

| Network | HTTP endpoint | WebSocket endpoint | Chain ID |
|---|---|---|---|
| Mainnet | `https://evm.confluxrpc.com` | `wss://evm.confluxrpc.com/ws` | `1030` / `0x406` |
| Mainnet China | `https://evmmain-china.confluxrpc.com` | - | `1030` / `0x406` |
| Mainnet Global | `https://evmmain-global.confluxrpc.com` | - | `1030` / `0x406` |
| Mainnet backup | `https://evm.confluxrpc.org` | `wss://evm.confluxrpc.org/ws` | `1030` / `0x406` |
| Testnet | `https://evmtestnet.confluxrpc.com` | `wss://evmtestnet.confluxrpc.com/ws` | `71` / `0x47` |
| Testnet alternate | `https://evmtest.confluxrpc.com` | - | `71` / `0x47` |
| Testnet backup | `https://evmtestnet.confluxrpc.org` | `wss://evmtestnet.confluxrpc.org/ws` | `71` / `0x47` |

## API-key URL pattern

Anonymous access is possible under guest limits. API-key users append the key as a path segment.

```text
https://main.confluxrpc.com/<api-key>
https://test.confluxrpc.com/<api-key>
https://evm.confluxrpc.com/<api-key>
https://evmtestnet.confluxrpc.com/<api-key>
```

Use the endpoint that matches the key's network and space.

## Core Space examples

### Status

```bash
curl -s -X POST https://main.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"cfx_getStatus","params":[],"id":1}'
```

### Epoch number

```bash
curl -s -X POST https://main.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"cfx_epochNumber","params":["latest_state"],"id":1}'
```

### Transaction receipt

```bash
curl -s -X POST https://main.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"cfx_getTransactionReceipt","params":["0xTX_HASH"],"id":1}'
```

### Wide historical `cfx_getLogs`

For Confura indexed log data, do not automatically split by a fixed epoch window when the filter is selective. If the contract/event is sparse, this can succeed in one request:

```bash
curl -s -X POST https://main.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{
    "jsonrpc":"2.0",
    "method":"cfx_getLogs",
    "params":[{
      "fromEpoch":"0x0",
      "toEpoch":"latest_state",
      "address":["cfx:TYPE.CONTRACT:ADDRESS"],
      "topics":[["0xEVENT_TOPIC0"]]
    }],
    "id":1
  }'
```

If the result set, response size, latency, or query-set size is too large, Confura may return a suggested block or epoch range. Retry with that suggested range and continue from the next block/epoch.

## eSpace examples

### Chain ID

```bash
curl -s -X POST https://evm.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
```

### Block number

```bash
curl -s -X POST https://evm.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Transaction receipt

```bash
curl -s -X POST https://evm.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["0xTX_HASH"],"id":1}'
```

### Wide historical `eth_getLogs`

```bash
curl -s -X POST https://evm.confluxrpc.com \
  -H 'Content-Type: application/json' \
  -d '{
    "jsonrpc":"2.0",
    "method":"eth_getLogs",
    "params":[{
      "fromBlock":"0x0",
      "toBlock":"latest",
      "address":"0xCONTRACT",
      "topics":["0xEVENT_TOPIC0"]
    }],
    "id":1
  }'
```

With Foundry:

```bash
cast logs 0xCONTRACT \
  --from-block 0 \
  --to-block latest \
  "Transfer(address,address,uint256)" \
  --rpc-url https://evm.confluxrpc.com
```

## Do users need to set a query range for getLogs?

For Confura indexed historical logs:

- If the user specifies a contract `address` and the matching logs are sparse, they do not need to pre-split by a fixed range.
- They may query a large range, including from genesis to latest indexed data.
- If the query is too large, Confura returns a suggested range; the client should follow it.
- If the user omits `address` and `topics`, a full-history query is likely too broad and should be avoided.
- If the query includes the newest not-yet-indexed blocks/epochs, that part may still be delegated to fullnodes and subject to split-range constraints.

Good pattern:

```text
wide range + contract address + optional topic0
  -> call once
  -> if suggested range error, follow suggestion
  -> continue remaining range
```

Bad pattern:

```text
wide range + no address + no topics
  -> likely too broad
```

## Common method groups

Use official RPC docs for full schemas. In this skill, explain only the common usage and Confura-specific behavior.

Core:

- status/head: `cfx_getStatus`, `cfx_epochNumber`, `cfx_getBestBlockHash`
- blocks: `cfx_getBlockByHash`, `cfx_getBlockByEpochNumber`, `cfx_getBlocksByEpoch`
- transactions: `cfx_getTransactionByHash`, `cfx_getTransactionReceipt`, `cfx_sendRawTransaction`
- state: `cfx_getAccount`, `cfx_getBalance`, `cfx_getNextNonce`, `cfx_getCode`, `cfx_getStorageAt`
- logs/filter: `cfx_getLogs`, `cfx_newFilter`, `cfx_getFilterChanges`
- diagnostics: `diagnostic_getRateLimitStatus` when the module is exposed

eSpace:

- status/head: `eth_blockNumber`, `eth_chainId`, `eth_gasPrice`
- blocks: `eth_getBlockByHash`, `eth_getBlockByNumber`
- transactions: `eth_getTransactionByHash`, `eth_getTransactionReceipt`, `eth_sendRawTransaction`
- state: `eth_getBalance`, `eth_getTransactionCount`, `eth_getCode`, `eth_call`
- logs/filter: `eth_getLogs`, `eth_newFilter`, `eth_getFilterChanges`
- diagnostics: `diagnostic_getRateLimitStatus` when the module is exposed
