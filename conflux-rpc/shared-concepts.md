# Shared Concepts

Cross-space concepts used by `conflux-rpc`. Confirm space and network before choosing methods or tools.

## Shared Concepts

- Address formats and normalization notes
- Unit conventions
- Read vs write boundary
- Mainnet write risk warning template

## Address Formats and Normalization

Conflux has two logically independent spaces with different address encodings. Do not mix formats across spaces.

| Space | Format | Example prefix / shape | Official reference |
|-------|--------|------------------------|--------------------|
| Core Space | CIP-37 Base32 string | Mainnet: `cfx:`; Testnet: `cfxtest:` | [Core Space addresses](https://doc.confluxnetwork.org/docs/core/core-space-basics/addresses) |
| eSpace | Ethereum-style hex (EIP-55 checksum) | `0x` + 40 hex chars | [eSpace accounts](https://doc.confluxnetwork.org/docs/espace/build/accounts) |

Normalization notes:

- Treat address prefix as a network signal. A `cfx:` address is Core mainnet; `cfxtest:` is Core testnet. A `0x` address belongs to eSpace, not Core.
- Core and eSpace accounts are separate namespaces. The same key pair can map to different address strings in each space.
- Cross-space operations use mapped addresses and dedicated bridge contracts; do not assume one address string works in both spaces. See [Spaces overview](https://doc.confluxnetwork.org/docs/general/conflux-basics/spaces) and [CrossSpaceCall](https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/crossSpaceCall).
- When passing addresses to RPC, use the format expected by the target namespace (`cfx_*` for Core, `eth_*` for eSpace).

## Unit Conventions

| Space | Native asset | Smallest unit | Typical RPC / SDK representation | Official reference |
|-------|--------------|---------------|----------------------------------|--------------------|
| Core Space | CFX | Drip | Balances and values often returned as Drip integers; `js-conflux-sdk` provides `Drip` helpers | [Core developer quickstart](https://doc.confluxnetwork.org/docs/core/core-developer-quickstart) |
| eSpace | CFX | wei (EVM convention) | Balances via `eth_getBalance` in wei; CLI tools may expose `--ether` conversion | [eSpace network endpoints](https://doc.confluxnetwork.org/docs/espace/network-endpoints) |

Additional notes:

- Core Space writes also involve **storage collateral** (separate from gas). Estimate with `cfx_estimateGasAndCollateral` before sending. See [storage](https://doc.confluxnetwork.org/docs/core/core-space-basics/storage) and [gas](https://doc.confluxnetwork.org/docs/general/conflux-basics/gas).
- Gas fields (`gas`, `gasPrice`, `maxFeePerGas`, etc.) are measured in gas units; fees are charged in the native smallest unit. Do not confuse gas units with CFX/Drip/wei amounts.

## Read vs Write Boundary

| Category | Allowed in this skill without private keys | Requires explicit user authorization |
|----------|--------------------------------------------|--------------------------------------|
| Read | Balance, account/state, read-only contract call, tx/receipt/log queries | — |
| Write guidance | Explain parameters, estimation steps, and preflight checks | User must supply signing material and confirm send |
| Write execution | — | Never sign or broadcast on behalf of the user |

Boundary rules:

- Default to read-only inspection when debugging ambiguous failures.
- For Core Space writes, run `cfx_estimateGasAndCollateral` and confirm network before any send step.
- For eSpace in v1, route deep troubleshooting to official docs; this skill does not provide full write playbooks for eSpace.
- For **eSpace-only** read-only inspection, prefer `conflux-scan-rpc`. For Core Space reads, use [core-space.md](core-space.md).

## Mainnet Write Risk Warning Template

Use this block verbatim (fill in the bracketed fields) before any **mainnet** write action:

```text
Mainnet write risk warning

You are about to send a state-changing transaction on Conflux [Core Space | eSpace] mainnet.

- Network: [mainnet RPC endpoint or network name]
- Space: [Core Space | eSpace]
- From: [sender address]
- To / contract: [target address]
- Value: [amount in CFX, with unit]
- Method / calldata summary: [brief description]

Risks:
- Transactions are irreversible once finalized.
- Mistakes in address, value, nonce, or gas fields can cause permanent asset loss.
- Mainnet fees and (for Core) storage collateral consume real CFX.

Required checks before send:
1. Re-confirm network is mainnet, not testnet.
2. Re-confirm sender, recipient/contract, and value.
3. For Core Space: `cfx_estimateGasAndCollateral` succeeded.
4. User explicitly approves send.

Proceed only after the user confirms they accept these risks.
```

For testnet writes, still confirm network and parameters, but replace the mainnet-specific loss language with testnet scope.

## Related References

- [Spaces (Core vs eSpace)](https://doc.confluxnetwork.org/docs/general/conflux-basics/spaces)
- [Accounts and addresses](https://doc.confluxnetwork.org/docs/general/conflux-basics/accounts)
- [Core JSON-RPC portal](https://doc.confluxnetwork.org/docs/core/build/json-rpc/)
- [eSpace JSON-RPC compatibility](https://doc.confluxnetwork.org/docs/espace/build/jsonrpc-compatibility)
