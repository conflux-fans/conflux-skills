---
name: conflux-docs
description: Points to official Conflux documentation — key concepts, eSpace/Core Space, RPC, deployment, and developer guides. Use when the user asks about Conflux, deployment, RPC, addresses, or needs reliable doc links.
---

# Conflux Documentation Helper

When the user asks about Conflux (concepts, deployment, RPC, addresses, tooling), respond with **exact links** to the official docs below. Do not invent URLs.

## Quick answers

- **eSpace testnet RPC?** `https://evmtestnet.confluxrpc.com` (chain ID 71). Mainnet: `https://evm.confluxrpc.com` (1030).
- **Testnet CFX?** https://efaucet.confluxnetwork.org/
- **eSpace vs Core?** eSpace = EVM-compatible, 0x addresses. Core = Conflux-native, CIP-37 addresses (e.g. `cfx:...`).

## When to use

- User asks "how does Conflux work?", "eSpace vs Core?", "where is the RPC?"
- User needs deployment, verification, or integration docs
- User asks about Conflux-specific concepts (spaces, consensus, gas, sponsorship)

## Key concepts and doc URLs

Base: **https://doc.confluxnetwork.org/docs/**

### Spaces (Core vs eSpace)

| Concept | URL |
|--------|-----|
| Space intro (Core + eSpace) | https://doc.confluxnetwork.org/docs/overview/space-intro |
| Spaces (address formats, independence) | https://doc.confluxnetwork.org/docs/general/conflux-basics/spaces |

eSpace = EVM-compatible, 0x addresses. Core = Conflux-native, CIP-37 addresses (e.g. `cfx:...`).

### eSpace (EVM)

| Topic | URL |
|-------|-----|
| User Guide (MetaMask, etc.) | https://doc.confluxnetwork.org/docs/espace/UserGuide |
| Developer Quickstart | https://doc.confluxnetwork.org/docs/espace/DeveloperQuickstart |
| Network RPC Endpoints | https://doc.confluxnetwork.org/docs/espace/network-endpoints |
| EVM Compatibility | https://doc.confluxnetwork.org/docs/espace/build/evm-compatibility |
| JSON-RPC Compatibility | https://doc.confluxnetwork.org/docs/espace/build/jsonrpc-compatibility |
| Cross-Space Bridge | https://doc.confluxnetwork.org/docs/espace/build/cross-space-bridge |
| ConfluxScan API | https://doc.confluxnetwork.org/docs/espace/build/infrastructure/confluxscan-api |

### Core Space

| Topic | URL |
|-------|-----|
| Getting Started | https://doc.confluxnetwork.org/docs/core/getting-started/ |
| Core Developer Quickstart | https://doc.confluxnetwork.org/docs/core/core-developer-quickstart |
| Core Space Basics | https://doc.confluxnetwork.org/docs/category/core-space-basics |
| Transactions (lifecycle, errors) | https://doc.confluxnetwork.org/docs/core/core-space-basics/transactions/overview |
| Storage (CFS) | https://doc.confluxnetwork.org/docs/core/core-space-basics/storage |
| Sponsor Mechanism | https://doc.confluxnetwork.org/docs/core/core-space-basics/sponsor-mechanism |
| Internal Contracts | https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/ |
| Run a Node | https://doc.confluxnetwork.org/docs/general/run-a-node/Overview |

### General (Conflux basics)

| Topic | URL |
|-------|-----|
| Documentation Overview | https://doc.confluxnetwork.org/docs/overview/ |
| Consensus (PoW + PoS) | https://doc.confluxnetwork.org/docs/general/conflux-basics/consensus-mechanisms/ |
| TreeGraph & GHAST | https://doc.confluxnetwork.org/docs/general/conflux-basics/consensus-mechanisms/proof-of-work/ |
| Proof of Stake | https://doc.confluxnetwork.org/docs/general/conflux-basics/consensus-mechanisms/proof-of-stake/pos_overview |
| Economics | https://doc.confluxnetwork.org/docs/general/conflux-basics/economics |
| Governance | https://doc.confluxnetwork.org/docs/general/conflux-basics/conflux-governance/governance-overview |
| Accounts | https://doc.confluxnetwork.org/docs/general/conflux-basics/accounts |
| Transactions | https://doc.confluxnetwork.org/docs/general/conflux-basics/transactions |
| Gas | https://doc.confluxnetwork.org/docs/general/conflux-basics/gas |

### Tutorials

| Topic | URL |
|-------|-----|
| eSpace tutorials (deploy, verify, etc.) | https://doc.confluxnetwork.org/docs/category/tutorials-1 |
| Core Space tutorials | https://doc.confluxnetwork.org/docs/category/tutorials |

## Quick reference

- **eSpace mainnet RPC:** https://evm.confluxrpc.com (chain ID 1030)
- **eSpace testnet RPC:** https://evmtestnet.confluxrpc.com (chain ID 71)
- **ConfluxScan (eSpace):** https://evm.confluxscan.org (mainnet), https://evmtestnet.confluxscan.org (testnet)
- **Testnet faucet:** https://efaucet.confluxnetwork.org/

For more concept links, see [reference.md](reference.md) in this skill.

## Related skills

- **conflux-scan-rpc** — inspect txs, receipts, balances (read-only).
- **conflux-dev** — deploy, verify contracts, integrate apps.
- **conflux-send-tx** — send txs (user review required).
- **conflux-agent-wallet** — generate wallet (no user key).
