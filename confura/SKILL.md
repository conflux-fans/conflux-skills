---
name: confura
description: Use, document, develop, deploy, and troubleshoot Confura, the Conflux public RPC gateway. Prioritize user-facing RPC service guidance: Core/eSpace endpoint selection, mainnet/testnet URLs, cfx_* vs eth_* methods, getLogs dynamic query bounds, oversized getLogs suggested ranges, rate-limit diagnostics, API-key usage, and common JSON-RPC errors. Also use for Confura architecture, rpc proxy, node manager, sync, virtual filters, metrics, and code changes in Conflux-Chain/confura.
metadata: {"requires":{"anyBins":["curl","go","make","docker","docker-compose"]}}
---

# Confura RPC Service

Confura is a full-node-compatible Conflux JSON-RPC gateway with indexed-storage and request-control features. When this skill is triggered, first help the user call the RPC service correctly; only then go into architecture, deployment, or code internals.

## Priority order

1. **RPC service usage for normal users**
   - choose Core Space vs eSpace
   - choose mainnet vs testnet endpoint
   - choose HTTP vs WebSocket
   - use API key URL paths when relevant
   - use `cfx_*` or `eth_*` examples
   - explain `getLogs` dynamic query bounds
   - diagnose rate limits and `-32005` errors

2. **Advanced user / SDK behavior**
   - implement robust `getLogs` scanning
   - parse oversized error messages with suggested block/epoch ranges
   - back off on rate limits
   - split only when Confura tells the client to split, not by fixed windows by default

3. **Operator / developer behavior**
   - run/build Confura
   - configure modules and rate limits
   - troubleshoot rpc proxy, node manager, sync, virtual filter, storage/cache, metrics, and fullnode fallback

## When to use

Use this skill when the user asks about:

- Confura public RPC endpoints.
- Mainnet/testnet, Core Space/eSpace, HTTP/WebSocket endpoint choices.
- Calling `cfx_*` or `eth_*` methods through Confura.
- `cfx_getLogs` or `eth_getLogs` behavior, especially broad historical queries.
- Whether a `getLogs` caller must set a fixed block/epoch query range.
- `getLogs` errors such as query set too large, result set too large, timeout, response too large, or suggested ranges.
- Rate-limit errors, QPS limits, daily quota, API keys, or `diagnostic_getRateLimitStatus`.
- Confura internals: RPC Proxy, Node Manager, Sync, Virtual Filter, Rate Limit, Metrics, Data Validator.
- Running, deploying, testing, or modifying `github.com/Conflux-Chain/confura`.

Do not use this skill for:

- General Conflux protocol explanations unrelated to Confura service behavior: use `conflux-docs`.
- Smart contract build/deploy/verify flows: use `conflux-dev`.
- Simple one-off chain lookups by transaction hash or address: use `conflux-scan-rpc`, unless the issue is specifically about Confura behavior.
- Sending transactions, managing private keys, or signing payloads.

## Core idea for normal RPC users

Confura is compatible with normal fullnode JSON-RPC, but has two important user-visible enhancements:

1. **Dynamic `getLogs` query bounds**
   - Indexed historical logs are not rejected merely because the user supplied a wide block/epoch range.
   - If the query is selective, for example it specifies a contract address and/or event topic and the matching logs are sparse, users may query a very large historical range, even genesis to latest indexed data.
   - If the query is too expensive or too large, Confura returns an oversized error with a suggested block or epoch range.
   - Clients should retry with the suggested range, then continue scanning the remaining range.

2. **Rate-limit diagnostics**
   - Confura rate-limits daily total requests and QPS.
   - Rate limits may be global or per method, for example `rpc_all_qps`, `cfx_getLogs_qps`, or `eth_getLogs_qps`.
   - When enabled by the server module configuration, `diagnostic_getRateLimitStatus` shows the effective strategy and whether the caller is identified by API key, IP, or Web3Pay info.

See:

- `reference-rpc-usage.md` for endpoints and ordinary RPC examples.
- `reference-getlogs-dynamic-bounds.md` for `getLogs` behavior.
- `reference-rate-limit-diagnostics.md` for throttling diagnosis.
- `reference-components.md` for Confura internals.
- `reference-deploy-ops.md` for build/run/deploy.
- `reference-getlogs-trace.md` for Core Space internal-contract trace logs.

## Endpoint quick reference

Use this rule first:

```text
Core Space  -> cfx_* methods, CIP-37/base32 addresses, chain IDs 1029 mainnet / 1 testnet
eSpace      -> eth_* methods, EVM 0x addresses, chain IDs 1030 mainnet / 71 testnet
```

| Space | Network | HTTP | WebSocket | Chain ID |
|---|---|---|---|---|
| Core | Mainnet | `https://main.confluxrpc.com` | `wss://main.confluxrpc.com/ws` | `1029` / `0x405` |
| Core | Testnet | `https://test.confluxrpc.com` | `wss://test.confluxrpc.com/ws` | `1` / `0x1` |
| eSpace | Mainnet | `https://evm.confluxrpc.com` | `wss://evm.confluxrpc.com/ws` | `1030` / `0x406` |
| eSpace | Testnet | `https://evmtestnet.confluxrpc.com` | `wss://evmtestnet.confluxrpc.com/ws` | `71` / `0x47` |

## Should this skill include every JSON-RPC method?

Do not inline the full JSON-RPC method catalog here. Instead:

- Explain endpoint selection and common method families.
- Provide common examples for status, block number, receipt, `getLogs`, and diagnostics.
- Route full schema lookups to the official RPC docs through `conflux-docs`.
- Keep Confura-specific service behavior here: dynamic `getLogs`, rate-limit diagnostics, trace logs, API-key paths, cache/index/fullnode fallback, and common public-service errors.

## `getLogs` guidance for user answers

When a user asks how to call `getLogs` through Confura:

1. Ask whether it is Core Space `cfx_getLogs` or eSpace `eth_getLogs`.
2. Tell them to specify at least a contract `address`; add `topics` when they know the event.
3. Do **not** blindly recommend fixed 1,000-block/epoch windows for indexed historical data.
4. For sparse contracts, it is acceptable to query a large range, even genesis to latest indexed data, as long as the result count, response size, latency, address count, topic count, and block-hash count stay within limits.
5. If Confura returns an error containing `a suggested block range is ...` or `a suggested epoch range is ...`, retry with that suggested range, then continue from the next block/epoch.
6. If the query touches the newest not-yet-indexed part, Confura may delegate that part to a fullnode, where configured split ranges still apply.
7. For early Core Space internal contracts, add `?includeTraceLogs` and follow `reference-getlogs-trace.md`.

## Rate-limit guidance for user answers

When a user says they are limited, throttled, or receiving `-32005`:

1. Identify whether the message is `daily request count exceeded` or `request rate exceeded`.
2. Identify whether the caller is using an API key path or anonymous/IP-based access.
3. Check whether the method is globally limited or method-limited, especially `getLogs` and `call`.
4. If the `diagnostic` module is exposed, call `diagnostic_getRateLimitStatus` through the same endpoint and API key.
5. Explain whether the returned `limitType` is `by_key`, by IP, or another user type.
6. Recommend client-side token bucket/backoff, request deduplication, lower polling frequency, narrower `getLogs`, or an upgraded API-key strategy as appropriate.
7. For operators, verify exposed modules, strategies, proxy real-IP headers, and configured resource names.

## Mental model

```text
Client
  -> Load Balancer
  -> RPC Proxy
      -> Storage / Cache / indexed logs
      -> Virtual Filter
      -> Node Manager
          -> Fullnode Pools

Sync
  -> Storage / Cache / indexed logs
```

`getLogs` is special because the indexed historical part can be served from storage, while the newest not-yet-indexed part may still fall through to upstream fullnodes.

## Build and local commands

Confura requires Go 1.22+.

```bash
go version
go build -o bin/confura
make build
```

Main component commands:

```bash
./confura sync --db
./confura sync --eth
./confura nm --cfx
./confura nm --eth
./confura vf --cfx
./confura vf --eth
./confura rpc --cfx
./confura rpc --cfxBridge
./confura rpc --eth
```

Data validation:

```bash
./confura test cfx --fn-endpoint http://FULLNODE --infura-endpoint http://RPC_PROXY
./confura test eth --fn-endpoint http://FULLNODE --infura-endpoint http://RPC_PROXY
./confura test ws  --fn-endpoint ws://FULLNODE --infura-endpoint ws://RPC_PROXY
./confura test vf  --fn-endpoint http://FULLNODE --infura-endpoint http://VIRTUAL_FILTER
```
