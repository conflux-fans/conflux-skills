# Network Matrix

Verified network mapping for `conflux-rpc`. Use official docs as the source of truth for RPC endpoints, chain IDs, and explorers. Do not copy unverified constants into commands.

## Network Matrix

Table columns:

- Space
- Network name
- Official docs entry link
- Notes

| Space | Network name | Official docs entry link | Notes |
|-------|--------------|--------------------------|-------|
| Core Space | Mainnet | https://doc.confluxnetwork.org/docs/core/conflux_rpcs | Chain ID `1029`; address prefix `cfx:`; JSON-RPC namespace `cfx_*`; explorer https://confluxscan.org |
| Core Space | Testnet | https://doc.confluxnetwork.org/docs/core/conflux_rpcs | Chain ID `1`; address prefix `cfxtest:`; JSON-RPC namespace `cfx_*`; explorer https://testnet.confluxscan.org |
| eSpace | Mainnet | https://doc.confluxnetwork.org/docs/espace/network-endpoints | Chain ID `1030`; `0x` addresses; JSON-RPC namespace `eth_*`; explorer https://evm.confluxscan.org |
| eSpace | Testnet | https://doc.confluxnetwork.org/docs/espace/network-endpoints | Chain ID `71`; `0x` addresses; JSON-RPC namespace `eth_*`; explorer https://evmtestnet.confluxscan.org |

## Usage Notes

- Pick **space first**, then **network**. Core and eSpace share the same ledger but use different RPC method families and address formats.
- Public RPC URLs, websocket endpoints, rate limits, and backup providers are listed in the official docs entry links above. Prefer the top-priority endpoint in each official list unless the user specifies otherwise.
- `js-conflux-sdk` `networkId` for Core testnet is `1` per the [Core developer quickstart](https://doc.confluxnetwork.org/docs/core/core-developer-quickstart); align SDK `networkId` with the target Core network when constructing clients.
- For read-only eSpace inspection patterns, see `conflux-scan-rpc`. For Core write workflows, see [core-space.md](core-space.md).

## Related References

- [Spaces overview](https://doc.confluxnetwork.org/docs/general/conflux-basics/spaces)
- [Core JSON-RPC portal](https://doc.confluxnetwork.org/docs/core/build/json-rpc/)
- [eSpace developer quickstart](https://doc.confluxnetwork.org/docs/espace/DeveloperQuickstart)
