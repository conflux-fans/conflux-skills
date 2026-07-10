---
name: conflux-rpc
description: Conflux RPC guidance with fully guided Core Space workflows and v1 eSpace navigation-only routing. Use when users ask for Conflux RPC method selection, call/send flows, transaction debugging, or Core vs eSpace command direction.
---

# conflux-rpc

## Scope

- Support Conflux RPC workflows with full Core Space guidance in v1.
- Fully support Core Space read and write guidance in this version.
- Keep eSpace as navigation-only in v1: route users to eSpace command style and method families, but avoid deep eSpace troubleshooting playbooks here.
- Apply when users ask about method selection, `call`/`send` flows, transaction debugging, or which command family matches Core vs eSpace.

## Intake

- Ask first when user did not specify space. Do not assume Core or eSpace from method names alone.
- Use a short routing question: "Are you operating in Core Space or eSpace? Is the network mainnet or testnet?"
- Collect minimum context before execution:
  - Space (`core` or `espace`)
  - Network (`mainnet`/`testnet` and RPC endpoint)
  - Intent (`read` vs `write`)
  - Target (address, tx hash, block, contract method)
- If context is incomplete, pause and ask clarifying questions before generating write commands.

## Tool Strategy

- Use a space-aware matrix and keep defaults explicit.

### Core Space

- Default: `js-conflux-sdk` v2+ (`conflux.cfx.*` API) for most Core Space flows.
- Optional: `cast rpc cfx_*` when user explicitly prefers Foundry CLI or needs quick single-call checks.
- Fallback: `curl` with raw JSON-RPC payloads for environment-agnostic verification.

### eSpace (v1 navigation-only)

- Default: `cast` for eSpace-style interactions.
- Optional: `cast rpc eth_*` for direct method inspection.
- Fallback: `curl` for raw JSON-RPC calls.
- Note: v1 does not provide full eSpace troubleshooting trees in this skill; route to dedicated eSpace references when deep diagnosis is requested.

## Safety Defaults

- Always confirm network before any write action. Never send writes to an implied endpoint.
- For Core Space writes, preflight `cfx_estimateGasAndCollateral` is required before send; do not construct or send transactions until it succeeds.
- Do not skip this preflight in v1.
- If estimation fails, stop and debug root cause before retrying writes.
- Show the write risk template from [shared-concepts.md](shared-concepts.md) before write operations, then wait for explicit user approval before any send step.
  - transactions are irreversible once finalized on mainnet
  - real asset loss is possible on parameter mistakes
  - user should verify to/from address, value, gas-related fields, and nonce assumptions
- Prefer read-only reproduction first when debugging ambiguous failures.

## Reference Files

Load only the file that matches the user's space and task:

- [core-space.md](core-space.md) — Core Space read/write workflows, estimation gate, and troubleshooting.
- [espace.md](espace.md) — eSpace v1 navigation index and official entry links.
- [shared-concepts.md](shared-concepts.md) — Address formats, units, read/write boundaries, and mainnet risk template.
- [network-matrix.md](network-matrix.md) — Verified network mapping and official RPC/explorer entry links.

## Related skills

- `conflux-scan-rpc` for **eSpace-only** read-only on-chain inspection and transaction state checks.
- `conflux-docs` for official Conflux documentation navigation and source grounding.
- `conflux-dev` for contract build, deploy, and integration workflows.
- For Core Space read-only queries, use [core-space.md](core-space.md) instead of `conflux-scan-rpc`.
- For cross-skill discovery and install details, see `SKILL_LIST.md`.

## Official References

- JSON-RPC portal (entry): <https://doc.confluxnetwork.org/docs/core/build/json-rpc/>
- `cfx_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/cfx-namespace>
- `pos_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/pos_rpc>
- `trace_*` methods: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/trace_rpc>
- Pub/Sub: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/pubsub>
- Common errors: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/common_rpc_error>
- Enums and shared types: <https://doc.confluxnetwork.org/docs/core/build/json-rpc/common-enums>
