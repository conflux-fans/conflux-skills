# Shared Concepts

Core Space concepts used by `conflux-core`. Confirm network before choosing methods or tools.

## Address Formats and Normalization

| Format | Example prefix / shape | Official reference |
|--------|------------------------|--------------------|
| CIP-37 Base32 (canonical) | Mainnet: `cfx:`; Testnet: `cfxtest:` | [Core Space addresses](https://doc.confluxnetwork.org/docs/core/core-space-basics/addresses) |
| Hex40 (internal) | `0x1` / `0x8` / `0x0` prefixes | Convert to CIP-37 before `cfx_*` RPC calls |

Normalization notes:

- A `cfx:` address is Core mainnet; `cfxtest:` is Core testnet.
- Core Space also accepts hex40 addresses internally; convert to CIP-37 (`cfx:` / `cfxtest:`) for SDK and most RPC examples. See [Core Space addresses](https://doc.confluxnetwork.org/docs/core/core-space-basics/addresses).
- Pass CIP-37 addresses to `cfx_*` methods unless the RPC docs explicitly allow hex40 for that call.

## Internal Contracts (brief)

Core Space includes seven built-in internal contracts. Use [internal-contracts.md](internal-contracts.md) for the canonical address table and method grouping.

- Only `CALL` and `STATICCALL` are valid for internal contracts. `CALLCODE` and `DELEGATECALL` fail.
- Read via `cfx_call` / `.call()` first when possible.
- For writes, keep the same sequence as normal contract writes: estimate -> explicit user approval -> send.
- For sponsor state checks, `cfx_getSponsorInfo` is the quickest RPC shortcut.

## Unit Conventions

| Native asset | Smallest unit | Typical RPC / SDK representation | Official reference |
|--------------|---------------|----------------------------------|--------------------|
| CFX | Drip | Balances and values as Drip integers; `js-conflux-sdk` provides `Drip` helpers | [Core developer quickstart](https://doc.confluxnetwork.org/docs/core/core-developer-quickstart) |

Additional notes:

- Core Space writes may also require **storage collateral** (separate from gas). See [Storage Collateral (brief)](#storage-collateral-brief) below.
- Gas fields (`gas`, `gasPrice`, etc.) are measured in gas units; fees are charged in Drip. Do not confuse gas units with CFX/Drip amounts.

## Storage Collateral (brief)

Core Space charges gas for execution and may lock CFX as storage collateral when a write occupies on-chain storage. Treat these as separate costs.

- Simple CFX transfers usually have zero storage collateral; contract writes and state changes may require non-zero collateral.
- Preflight with `cfx_estimateGasAndCollateral` before any send. Review `storageCollateralized` and `storageLimit` alongside gas fields.
- Ensure the sender balance covers both gas fees and storage collateral on mainnet.
- Collateral is locked while storage is occupied; it can be released when that storage is freed. See [Storage (CFS)](https://doc.confluxnetwork.org/docs/core/core-space-basics/storage) for mechanism details.
- Estimation, send flow, and collateral troubleshooting: [core-space.md](core-space.md).

## Read vs Write Boundary

| Category | Allowed in this skill without private keys | Requires explicit user authorization |
|----------|--------------------------------------------|--------------------------------------|
| Read | Balance, account/state, read-only contract call, tx/receipt queries | — |
| Write guidance | Explain parameters, estimation steps, and preflight checks | User must supply signing material and confirm send |
| Write execution | — | Never sign or broadcast on behalf of the user |

Boundary rules:

- Default to read-only inspection when debugging ambiguous failures.
- For writes, run `cfx_estimateGasAndCollateral` and confirm network before any send step.
- Detailed read/write patterns: [core-space.md](core-space.md).

## Mainnet Write Risk Warning Template

Use this block verbatim (fill in the bracketed fields) before any **mainnet** write action:

```text
Mainnet write risk warning

You are about to send a state-changing transaction on Conflux Core Space mainnet.

- Network: [mainnet RPC endpoint or network name]
- From: [sender address]
- To / contract: [target address]
- Value: [amount in CFX, with unit]
- Method / calldata summary: [brief description]

Risks:
- Transactions are irreversible once finalized.
- Mistakes in address, value, nonce, or gas fields can cause permanent asset loss.
- Mainnet fees and storage collateral consume real CFX.

Required checks before send:
1. Re-confirm network is mainnet, not testnet.
2. Re-confirm sender, recipient/contract, and value.
3. `cfx_estimateGasAndCollateral` succeeded.
4. User explicitly approves send.

Proceed only after the user confirms they accept these risks.
```

For testnet writes, still confirm network and parameters, but replace the mainnet-specific loss language with testnet scope.

## Related References

- [Core Space addresses](https://doc.confluxnetwork.org/docs/core/core-space-basics/addresses)
- [Core Space accounts](https://doc.confluxnetwork.org/docs/core/core-space-basics/accounts)
- [Storage (CFS)](https://doc.confluxnetwork.org/docs/core/core-space-basics/storage)
- [Gas](https://doc.confluxnetwork.org/docs/general/conflux-basics/gas)
- [Core JSON-RPC portal](https://doc.confluxnetwork.org/docs/core/build/json-rpc/)
- [Internal contracts (official)](https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/)
- [Internal contracts guide](internal-contracts.md)
