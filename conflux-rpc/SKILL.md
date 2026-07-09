---
name: conflux-rpc
description: Core Space-first Conflux RPC guidance with Core/eSpace routing, read-write troubleshooting flows, and safe defaults. Use when users ask for Conflux RPC methods, call/send flows, tx debugging, or space-specific command choices.
---

# conflux-rpc

## Scope

- Support Conflux RPC workflows with a Core Space-first default in v1.
- Fully support Core Space read and write guidance in this version.
- Keep eSpace as navigation-only in v1: route users to eSpace command style and method families, but avoid deep eSpace troubleshooting playbooks here.
- Apply when users ask about method selection, `call`/`send` flows, transaction debugging, or which command family matches Core vs eSpace.

## Intake

- Ask first when user did not specify space. Do not assume Core or eSpace from method names alone.
- Use a short routing question: "你要操作 Core Space 还是 eSpace？网络是 mainnet 还是 testnet？"
- Collect minimum context before execution:
  - Space (`core` or `espace`)
  - Network (`mainnet`/`testnet` and RPC endpoint)
  - Intent (`read` vs `write`)
  - Target (address, tx hash, block, contract method)
- If context is incomplete, pause and ask clarifying questions before generating write commands.

## Tool Strategy

- Use a space-aware matrix and keep defaults explicit.

### Core Space

- Default: `js-conflux-sdk` for most Core Space flows.
- Optional: `cast rpc cfx_*` when user explicitly prefers Foundry CLI or needs quick single-call checks.
- Fallback: `curl` with raw JSON-RPC payloads for environment-agnostic verification.

### eSpace (v1 navigation-only)

- Default: `cast` for eSpace-style interactions.
- Optional: `cast rpc eth_*` for direct method inspection.
- Fallback: `curl` for raw JSON-RPC calls.
- Note: v1 does not provide full eSpace troubleshooting trees in this skill; route to dedicated eSpace references when deep diagnosis is requested.

## Safety Defaults

- Always confirm network before any write action. Never send writes to an implied endpoint.
- For Core Space writes, require preflight `cfx_estimateGasAndCollateral` before constructing or sending transactions.
- If estimation fails, stop and debug root cause before retrying writes.
- Show explicit mainnet risk warning before write operations:
  - transactions are irreversible once finalized
  - real asset loss is possible on parameter mistakes
  - user should verify to/from address, value, gas-related fields, and nonce assumptions
- Prefer read-only reproduction first when debugging ambiguous failures.

## Official References

- JSON-RPC portal (entry): <https://doc.confluxnetwork.org/docs/core/build/json-rpc/>
- `cfx_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/cfx-namespace>
- `pos_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/pos-namespace>
- `trace_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/trace-namespace>
- Pub/Sub: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/pubsub>
- Common errors: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/common_rpc_error>
- Enums and shared types: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/rpc-types-and-enums>
