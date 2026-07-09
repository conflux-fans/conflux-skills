# eSpace

## eSpace Status in v1

This file is navigation-only in v1.
Do not treat it as complete eSpace implementation guidance.

> v1 navigation-only placeholder: this page is intentionally a routing index for quick navigation, not a full RPC encyclopedia.

## Official Entry

- Main eSpace entry: https://doc.confluxnetwork.org/docs/espace/DeveloperQuickstart
- Common `eth_*` RPC methods entry: https://doc.confluxnetwork.org/docs/espace/build/jsonrpc-compatibility
- Network endpoints: https://doc.confluxnetwork.org/docs/espace/network-endpoints
- Tx/receipt/logs troubleshooting entry: https://doc.confluxnetwork.org/docs/general/faq/community-faqs/#how-to-check-the-reason-for-transaction-failure

## Recommended Reading Order

1. Start from the Developer Quickstart to understand environment, tooling, and network context.
2. Then read the common `eth_*` methods entry for day-to-day query and transaction APIs.
3. Use the community FAQ entry (and `conflux-scan-rpc` for read-only receipt/log inspection) when diagnosing pending tx, failed receipt, or missing log issues.

## Semantic Boundary (Core vs eSpace)

- Choose tooling and methods based on space first.
- Do not directly copy Core Space semantics to eSpace.
- Do not assume `cfx_*` naming, parameter interpretation, or error patterns apply to `eth_*` endpoints.
- When behavior differs, prioritize eSpace documentation and method-specific notes.
