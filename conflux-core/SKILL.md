---
name: conflux-core
description: Core Space RPC guidance for read/write flows, cfx_* method selection, contract calls, transaction debugging, and safe send defaults. Use when users work with Conflux Core Space JSON-RPC, js-conflux-sdk, or cast rpc cfx_*.
---

# conflux-core

## Scope

- Core Space RPC only: read, write guidance, estimation, and troubleshooting.
- Apply when users ask about `cfx_*` methods, Core addresses (`cfx:` / `cfxtest:`), `cfx_call`, `cfx_estimateGasAndCollateral`, `cfx_sendTransaction`, or Core transaction debugging.
- Do not use this skill for eSpace (`eth_*`) workflows.

## Intake

- Confirm network before execution: mainnet or testnet, and the RPC endpoint.
- Collect minimum context:
  - Network (`mainnet`/`testnet` and RPC URL)
  - Intent (`read` vs `write`)
  - Target (address, tx hash, contract, method)
- If context is incomplete, pause and ask clarifying questions before generating write commands.

## Tool Strategy

- Default: `js-conflux-sdk` v2+ (`conflux.cfx.*` API) for most Core Space flows.
- Optional: `cast rpc cfx_*` when the user prefers Foundry CLI or needs quick single-call checks.
- Fallback: `curl` with raw JSON-RPC payloads for environment-agnostic verification.
- Respect user-specified tool preference when stated.

## Safety Defaults

- Always confirm network before any write action. Never send writes to an implied endpoint.
- Preflight `cfx_estimateGasAndCollateral` is required before send; do not construct or send transactions until it succeeds.
- If estimation fails, stop and debug root cause before retrying writes.
- Show the write risk template from [shared-concepts.md](shared-concepts.md) before write operations, then wait for explicit user approval before any send step.
  - transactions are irreversible once finalized on mainnet
  - real asset loss is possible on parameter mistakes
  - user should verify to/from address, value, gas-related fields, and nonce assumptions
- Prefer read-only `cfx_call` reproduction before sending when debugging contract interactions.

## Reference Files

- [core-space.md](core-space.md) — Read/write workflows, contract calls, estimation gate, and troubleshooting.
- [shared-concepts.md](shared-concepts.md) — Core addresses, units, storage collateral, read/write boundaries, and mainnet risk template.
- [network-matrix.md](network-matrix.md) — Core mainnet/testnet mapping and official RPC/explorer entry links.

## Related skills

- `conflux-docs` — official Conflux documentation navigation and source grounding.
- For cross-skill discovery and install details, see `SKILL_LIST.md`.

## Official References

- JSON-RPC portal (entry): <https://doc.confluxnetwork.org/docs/core/build/json-rpc/>
- `cfx_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/cfx-namespace>
- `pos_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/pos_rpc>
- `trace_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/trace_rpc>
- Pub/Sub: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/pubsub>
- Common errors: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/common_rpc_error>
- Enums and shared types: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/common-enums>
