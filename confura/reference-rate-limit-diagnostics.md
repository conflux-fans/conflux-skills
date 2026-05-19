# Rate Limit Diagnostics

Confura exposes user-visible rate-limit behavior and, when enabled, a diagnostic RPC method.

## What gets limited

Confura can limit:

- daily total requests: `rpc_all_daily`
- global QPS: `rpc_all_qps`
- per-method QPS: examples include `cfx_getStatus_qps`, `cfx_getLogs_qps`, `eth_getLogs_qps`

Strategies may use:

- `fixed_window`
- `token_bucket`

Users may be identified by:

- API key
- client IP
- Web3Pay information

## User-visible error

When limited, Confura returns JSON-RPC error code:

```text
-32005
```

Common messages:

```text
daily request count exceeded
request rate exceeded
```

| Error message | Meaning | User action |
|---|---|---|
| `daily request count exceeded` | quota used up for the current daily window | reduce total calls, use API key, upgrade strategy, cache client-side |
| `request rate exceeded` | QPS/burst exceeded | add backoff, token bucket, reduce polling, batch/dedupe calls |
| limited on `getLogs` | expensive method exceeded method-specific budget | use selective filters, follow suggested ranges, lower concurrency |

## diagnostic_getRateLimitStatus

When the server exposes the `diagnostic` module, users can call:

```text
diagnostic_getRateLimitStatus
```

Example:

```bash
curl -X POST https://main.confluxrpc.com/<api-key> \
  -H 'Content-Type: application/json' \
  -d '{
    "jsonrpc": "2.0",
    "method": "diagnostic_getRateLimitStatus",
    "params": [],
    "id": 1
  }'
```

Example response shape:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "strategy": {
      "ID": 1,
      "Name": "vip1",
      "LimitOptions": {
        "rpc_all_daily": {"Interval": 86400000000000, "Quota": 1000000},
        "rpc_all_qps": {"Rate": 20, "Burst": 40}
      }
    },
    "limitType": "by_key",
    "info": {
      "userType": "provisioned_user",
      "clientIp": "203.0.113.10",
      "apiKey": "example-api-key"
    }
  }
}
```

An empty result means no matching strategy was resolved for the current request context.

## Important caveat

The `diagnostic` module is not necessarily public by default. Operators must include it in the RPC server's exposed modules before `diagnostic_getRateLimitStatus` can be called.

If users receive "method not found" or a module exposure error, they should ask the service operator whether `diagnostic` is enabled.

## Troubleshooting workflow for ordinary users

1. Confirm the endpoint and network.
2. Confirm whether the request uses an API key path.
3. Check the exact JSON-RPC error: daily quota or QPS.
4. If available, call `diagnostic_getRateLimitStatus` using the same endpoint and API key.
5. Inspect `strategy.Name`, `LimitOptions`, `limitType`, `info.clientIp`, and `info.apiKey`.
6. Apply mitigation: client-side token bucket, backoff with jitter, dedupe calls, cache static results, reduce polling, narrow high-cost `getLogs`, lower concurrent `eth_call` / `cfx_call`, or use a provisioned API key.

## Troubleshooting workflow for operators

Check:

- Is `diagnostic` included in `rpc.exposedModules` / `ethrpc.exposedModules` if users need diagnostics?
- Is real client IP preserved by the load balancer through `X-Forwarded-For` and `X-Real-IP`?
- Are anonymous users unexpectedly grouped behind one proxy IP?
- Are API-key strategies being resolved correctly?
- Are method-specific resources configured, for example `cfx_getLogs_qps`, `eth_getLogs_qps`, `cfx_call_qps`, `eth_call_qps`?
- Are high-cost methods separated from cheap point queries?
- Are dashboard metrics broken down by method, API key/user type, error code, and endpoint?
