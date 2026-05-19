# getLogs with Dynamic Query Bounds

Confura's most important user-facing RPC enhancement is dynamic handling of `cfx_getLogs` and `eth_getLogs`.

## Fullnode behavior vs Confura behavior

A plain fullnode usually protects itself by enforcing a relatively small fixed block or epoch range for log queries.

Confura is different for indexed historical logs:

```text
plain fullnode:
  reject broad range early

Confura indexed logs:
  accept broad range
  evaluate actual work produced by the filter
  return logs if within result/size/latency limits
  otherwise return an error with a suggested range
```

This means client applications do not need to blindly split every `getLogs` query into fixed 1,000 block/epoch windows.

## What users should do

For ordinary callers:

1. Always include a contract `address` when possible.
2. Include `topics[0]` when the target event is known.
3. Use a broad historical range when the filter is selective.
4. If Confura returns a suggested block/epoch range, retry using that range.
5. Continue from the next block/epoch after the suggested range until the original target range is covered.

## Practical limits

| Limit dimension | Meaning |
|---|---|
| result count | one response can contain up to `10,000` logs |
| response size | default getLogs response body limit is `10 MB` |
| latency | indexed log queries time out after the configured maximum duration, currently `3s` by default |
| filter complexity | address count, topic count, and block-hash count are capped |
| query-set size | candidate search space is capped before exact topic/result validation |

## SuggestedFilterOversizedError

When a query is too large, Confura returns an error that preserves the original reason and appends a suggested range.

Examples:

```text
the result set exceeds the max limit of 10000 logs, please narrow down your filter conditions: a suggested block range is [1000000, 1234567]
```

```text
the query set is too large, please narrow down your filter condition: a suggested epoch range is [90000000, 90001000]
```

Internally, this is represented by:

```go
SuggestedFilterOversizedError[SuggestedBlockRange]
SuggestedFilterOversizedError[SuggestedEpochRange]
```

This is not necessarily a standalone JSON-RPC method. It is primarily an enhanced error returned by `getLogs`.

## Client retry algorithm

Use this algorithm in SDKs and indexers:

```text
target = [from, to]

call getLogs(target)

if success:
  return logs

if error contains "a suggested block range is [a, b]":
  call getLogs([a, b])
  continue from b + 1 to target.to

if error contains "a suggested epoch range is [a, b]":
  call getLogs([a, b])
  continue from b + 1 to target.to

if oversized error has no suggestion:
  split range manually, usually by half

if timeout:
  split range smaller and retry with backoff

if rate-limited:
  back off or inspect diagnostic_getRateLimitStatus
```

Never retry the exact same oversized range unchanged.

## Why specifying contract address can avoid manual ranges

The key point is selectivity.

```text
good:
  full history + one contract address + event topic
  -> may return under 10,000 logs and under 10 MB

bad:
  full history + no address + no topic
  -> enormous candidate set
```

For low-frequency contracts, a full-history query with an address can be cheaper than thousands of artificially split requests.

## Fullnode delegation caveat

Confura may still delegate the newest, not-yet-indexed part of a log query to an upstream fullnode. That delegated portion is still subject to configured fullnode split ranges.

Once data has been indexed, Confura's dynamic result-size and latency controls apply.

## Implementation-level details

Important defaults and code-level constants:

| Item | Value | Meaning |
|---|---:|---|
| `MaxLogLimit` | `10000` | maximum logs returned by one query |
| `TimeoutGetLogs` | `3s` | store-level getLogs timeout |
| `maxLogQuerySetSize` | `100000` | maximum candidate query-set size |
| `MaxLogBlockHashesSize` | config default `32` | max block hashes in a filter |
| `MaxLogFilterAddrCount` | config default `32` | max addresses in a filter |
| `MaxLogFilterTopicCount` | config default `32` | max topics per topic dimension |
| `MaxLogEpochRange` | config default `1000` | split epoch range for fullnode-side filters |
| `MaxLogBlockRange` | config default `1000` | split block range for fullnode-side filters |
| `MaxGetLogsResponseBytes` | config default `10485760` | default 10 MB response body limit |

MySQL indexed-log validation:

```text
calculate query-set size
  -> if candidate set too large and topics are present
       return query-set-too-large with suggested block range when possible
  -> else validate result size
       return result-set-too-large with suggested block range when possible
  -> else execute query
```

## Wording to use in user-facing answers

Prefer:

```text
Confura does not require fixed window splitting for every indexed getLogs query. If you specify a contract address and the matching logs are sparse, you can query a large historical range. If the query is too large, follow the suggested range in the error message.
```

Avoid:

```text
Always query getLogs in 1000-block windows.
```
