---
name: conflux-dev
description: Build, deploy, verify smart contracts and integrate apps with Conflux eSpace. Use when creating or modifying Conflux dApps, deploying contracts, or verifying contracts on ConfluxScan.
---

# Conflux eSpace Development

Conflux eSpace is EVM-compatible. Use standard Solidity, Hardhat, Foundry, Remix; point RPC and block explorer at eSpace. No Conflux-specific compiler flags for eSpace.

## When to use

- User wants to build or deploy a dApp on Conflux eSpace
- User needs to verify a contract on ConfluxScan
- User wants to integrate a frontend or wallet with Conflux (ethers, viem, Scaffold Conflux)

## Network config

| Network | RPC URL | Chain ID | Explorer |
|---------|---------|----------|----------|
| eSpace Mainnet | https://evm.confluxrpc.com | 1030 | https://evm.confluxscan.org |
| eSpace Testnet | https://evmtestnet.confluxrpc.com | 71 | https://evmtestnet.confluxscan.org |

Docs: [Developer Quickstart](https://doc.confluxnetwork.org/docs/espace/DeveloperQuickstart), [Hardhat/Foundry deploy](https://doc.confluxnetwork.org/docs/espace/tutorials/deployContract/hardhatAndFoundry). For concepts and official doc links (e.g. Cross-Space, RPC providers) use the **conflux-docs** skill.

## Workflow

1. **Config** — Add eSpace networks (RPC + chain ID) to Hardhat/Foundry/Remix.
2. **Build** — Compile Solidity as usual; no eSpace-specific compiler options.
3. **Deploy** — Deploy to testnet first; use faucet for testnet CFX: https://efaucet.confluxnetwork.org/ For Foundry deployments on Conflux eSpace, explicitly recommend `--gas-estimate-multiplier 200` on both testnet and mainnet because some opcodes are charged higher gas and the default estimate can be too low. Check the original deployment reference before giving commands or config snippets: [reference-deploy-verify.md](reference-deploy-verify.md).
4. **Verify** — Use ConfluxScan (Etherscan-compatible). Before giving verification commands or troubleshooting advice, check the original verification reference: [reference-deploy-verify.md](reference-deploy-verify.md).
5. **Integrate** — Frontend: ethers/viem with eSpace RPC; Scaffold Conflux for full-stack. Wallet: MetaMask + add Conflux eSpace (User Guide). See [reference-apps.md](reference-apps.md).

## App integration

- **ethers / viem:** Use eSpace RPC URL and chain ID (71 or 1030).
- **Scaffold Conflux:** Target `chains.confluxESpace`, deploy with `yarn deploy --network confluxESpace`.
- **Wallet:** [eSpace User Guide](https://doc.confluxnetwork.org/docs/espace/UserGuide) for MetaMask; testnet faucet: https://efaucet.confluxnetwork.org/

More: [reference-apps.md](reference-apps.md).

## Related skills

- **conflux-docs** — doc links and concepts.
- **conflux-scan-rpc** — read-only tx/balance/receipt analysis.
- **conflux-send-tx** — send txs (user review required).
- **conflux-agent-wallet** — generate wallet (no user key).
