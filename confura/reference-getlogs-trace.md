# Core Space Internal Contract Trace Logs

Early Conflux Core Space internal contracts did not emit standard event logs. Confura can reconstruct synthetic logs from trace data and expose them through `cfx_getLogs`.

## Enable trace logs

Append the query parameter to the Core Space RPC endpoint:

```text
https://main.confluxrpc.com/?includeTraceLogs
https://main.confluxrpc.com/?includeTraceLogs=true
```

The JSON-RPC method remains `cfx_getLogs`.

## Supported internal contracts

| Contract | Mainnet | Testnet |
|---|---|---|
| Staking | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajrwuc9jnb` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajh3dw3ctn` |
| SponsorWhitelistControl | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaegg2r16ar` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaeprn7v0eh` |
| AdminControl | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2mhjju8k` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaawby2s44d` |

## Query constraints

| Scenario | Behavior |
|---|---|
| `address` contains only supported internal contracts | returns synthetic event logs from trace data |
| `address` is omitted or contains only normal/unsupported contracts | normal `cfx_getLogs`; `includeTraceLogs` has no effect |
| `address` mixes supported internal contracts with other addresses | returns an error |

Split mixed internal-contract and normal-contract queries into separate requests.

## Success rules

Emit a synthetic event only when:

1. the whole transaction succeeded
2. the current internal contract call succeeded
3. every ancestor call succeeded

If an ancestor call reverts, do not emit the synthetic log.
