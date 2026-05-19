# Confura AI Task Patterns

## For ordinary RPC users

Start with:

1. Which endpoint should they call?
2. Which method family is correct: `cfx_*` or `eth_*`?
3. Are they using mainnet/testnet correctly?
4. Are they passing an API key path if they expect provisioned limits?
5. For `getLogs`, is there a contract address and topic?
6. For rate limits, is the error daily quota or QPS?

## For getLogs answers

Use this answer structure:

```text
Because Confura uses indexed logs, you do not need to split every query by a fixed range. If you specify the contract address and the matching logs are sparse, you can query a large historical range. If Confura says the query is too large, parse the suggested block/epoch range from the error, retry with that range, and continue scanning the remaining range.
```

## For rate-limit answers

Use this answer structure:

```text
The -32005 error means the request matched a rate-limit strategy. daily request count exceeded means quota; request rate exceeded means QPS/burst. If diagnostic_getRateLimitStatus is exposed, call it with the same endpoint/API key to inspect strategy, limitType, and caller identity.
```

## Code-review checklist

- Core/eSpace separation is correct.
- Context cancellation and timeout propagate.
- Indexed storage/cache path is used before fullnode fallback where intended.
- `getLogs` oversized errors preserve suggested ranges.
- Rate-limit resources use correct method names.
- Metrics report final outcome once.
- Recent not-yet-indexed logs are handled safely.
- Fullnode fallback does not create a high-cost query storm.
- Tests cover broad sparse getLogs, dense getLogs, timeout, suggested ranges, and rate-limit errors.
