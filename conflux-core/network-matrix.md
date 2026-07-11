# Network Matrix

Verified Core Space network mapping for `conflux-core`. Use official docs as the source of truth for RPC endpoints, chain IDs, and explorers. Do not copy unverified constants into commands.

## Network Matrix

| Network name | Official docs entry link | Notes |
|--------------|--------------------------|-------|
| Mainnet | https://doc.confluxnetwork.org/docs/core/conflux_rpcs | Chain ID `1029`; address prefix `cfx:`; JSON-RPC namespace `cfx_*`; explorer https://confluxscan.org |
| Testnet | https://doc.confluxnetwork.org/docs/core/conflux_rpcs | Chain ID `1`; address prefix `cfxtest:`; JSON-RPC namespace `cfx_*`; explorer https://testnet.confluxscan.org |

## Usage Notes

- Set both `CFX_RPC_URL` and `CFX_CHAIN_ID` to match the target network (see table above).
- Public RPC URLs, websocket endpoints, rate limits, and backup providers are listed in the official docs entry links. Prefer the top-priority endpoint in each official list unless the user specifies otherwise.
- `js-conflux-sdk` `networkId` for Core testnet is `1` per the [Core developer quickstart](https://doc.confluxnetwork.org/docs/core/core-developer-quickstart); align SDK `networkId` with the target Core network when constructing clients.
- Read/write workflows: [core-space.md](core-space.md).

## Related References

- [Core JSON-RPC portal](https://doc.confluxnetwork.org/docs/core/build/json-rpc/)
- [Core RPC endpoints](https://doc.confluxnetwork.org/docs/core/conflux_rpcs)
