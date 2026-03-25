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
3. **Deploy** — Deploy to testnet first; use faucet for testnet CFX: https://efaucet.confluxnetwork.org/
4. **Verify** — Use ConfluxScan (Etherscan-compatible). Hardhat: custom chains + `hardhat verify`. Foundry: `forge verify-contract` with `--verifier-url` to ConfluxScan API. See [reference-deploy-verify.md](reference-deploy-verify.md).
5. **Integrate** — Frontend: ethers/viem with eSpace RPC; Scaffold Conflux for full-stack. Wallet: MetaMask + add Conflux eSpace (User Guide). See [reference-apps.md](reference-apps.md).

## Quick deploy

**Hardhat:** Set `networks.eSpaceTestnet.url` and `chainId: 71` (or mainnet 1030). Run `npx hardhat run scripts/deploy.js --network eSpaceTestnet`.

**Foundry:** `forge create --rpc-url https://evmtestnet.confluxrpc.com src/Contract.sol:Contract --private-key <KEY>`.

**Remix:** Add Conflux eSpace Testnet in MetaMask (chain ID 71, RPC above), then deploy via "Injected Provider".

## Verify on ConfluxScan

- **Hardhat:** Configure `etherscan` with ConfluxScan API URL and run `npx hardhat verify --network <network> <address> [constructor args]`.
- **Foundry:** `forge verify-contract <address> <ContractName> --verifier-url https://evmapi-testnet.confluxscan.org/api/ --etherscan-api-key any` (do not pass chain ID).

Details and config snippets: [reference-deploy-verify.md](reference-deploy-verify.md).

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
