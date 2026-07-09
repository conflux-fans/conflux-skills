# eSpace

> v1 navigation-only placeholder: this page is intentionally a routing index for quick navigation, not a full RPC encyclopedia.

## Official Entry

- Main eSpace entry: https://doc.confluxnetwork.org/docs/espace
- Common `eth_*` RPC methods entry: https://doc.confluxnetwork.org/docs/espace/build/jsonrpc-compatibility
- Tx/receipt/logs troubleshooting entry: https://doc.confluxnetwork.org/docs/espace/build/troubleshooting

## Recommended Reading Order

1. Start from the main eSpace entry to understand environment, account model, and network context.
2. Then read the common `eth_*` methods entry for day-to-day query and transaction APIs.
3. Use the tx/receipt/logs troubleshooting entry when diagnosing pending tx, failed receipt, or missing log issues.

## Semantic Boundary (Core vs eSpace)

- Do not directly copy Core Space semantics to eSpace.
- Do not assume `cfx_*` naming, parameter interpretation, or error patterns apply to `eth_*` endpoints.
- When behavior differs, prioritize eSpace documentation and method-specific notes.
