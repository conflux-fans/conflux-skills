# Confura Component Reference

Use this file when the user asks about Confura internals, architecture, operations, or code changes. For ordinary RPC users, start with `reference-rpc-usage.md`.

## System architecture

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

Data Validator
  -> Fullnode
  -> RPC Proxy / Virtual Filter
```

## Component responsibility map

| Component | Responsibility | Common failure modes | First checks |
|---|---|---|---|
| RPC Proxy | Public RPC entry; routes to storage/cache, Virtual Filter, or fullnode | timeout, wrong route, cache miss storm, inconsistent result | method path, proxy logs, upstream, storage hit/miss |
| Sync | Indexes chain data into DB/cache | sync lag, missing historical data, DB bottleneck, reorg handling | indexed height/epoch, DB status, fullnode source |
| Node Manager | Manages fullnode pools and health | unhealthy node selected, lagging node, exhausted pool | node height, heartbeat, latency, error rate |
| Virtual Filter | Stores filter state outside fullnodes | missing filter changes, polling lag | poll loop, backend state, fullnode comparison |
| Rate Limit | Protects service resources | false throttling, noisy tenant, abuse | strategy, API key/IP, resource name |
| Metrics | RED observability | missing SLO signal | rate, error, duration by method/user/endpoint |
| Data Validator | Compares proxy/VF output with fullnode | false positives from reorg/lag | stable range, same method/params |

## Death spiral model

```text
High-cost requests
  x High-frequency callers
  x Weak resource isolation
  x Cache/index miss
  x Fullnode fallback
  -> Fullnode latency and lag
  -> Sync lag
  -> Lower cache hit rate
  -> More fullnode fallback
  -> System overload
```
