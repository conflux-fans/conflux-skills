# conflux-skills

Small collection of reusable Codex skills for Conflux-related development workflows.

## Project structure

```text
.
├── README.md
├── SKILL_LIST.md
├── conflux-dev/
│   ├── SKILL.md
│   ├── reference-apps.md
│   └── reference-deploy-verify.md
├── conflux-docs/
│   ├── SKILL.md
│   └── reference.md
├── conflux-rust-integration-test/
│   ├── SKILL.md
│   ├── assets/
│   └── references/
├── conflux-scan-rpc/
│   ├── SKILL.md
│   └── api-endpoints.md
├── conflux-core/
│   ├── SKILL.md
│   ├── core-space.md
│   ├── network-matrix.md
│   └── shared-concepts.md
├── conflux-eip-6963-wallet/
│   ├── SKILL.md
│   └── reference-patterns.md
```

## Available skills

See [SKILL_LIST.md](SKILL_LIST.md) for the central list of all skills, GitHub URLs, and install commands.

### conflux-dev

Build, deploy, verify smart contracts, and integrate frontends or wallets with Conflux eSpace using standard EVM tooling such as Hardhat, Foundry, Remix, ethers, and viem.

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-dev
```

### conflux-rust-integration-test

Create or update pytest-based integration tests for `conflux-rust`, including fixture reuse, framework customization, and test run/debug patterns.

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-rust-integration-test
```

### conflux-docs

Provide official Conflux documentation links for concepts, Core Space/eSpace differences, RPC endpoints, deployment, and developer guides.

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-docs
```

### conflux-scan-rpc

Run read-only Conflux eSpace state inspection workflows (transactions, receipts, balances, and contract state) via RPC and ConfluxScan API.

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-scan-rpc
```

### conflux-core

Core Space RPC workflows: `cfx_*` read/write guidance, contract calls, transaction debugging, and safe send defaults (preflight `cfx_estimateGasAndCollateral`, network confirmation, explicit user approval).

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-core
```

### conflux-eip-6963-wallet

Generate modern multi-wallet connect flows with EIP-6963 instead of legacy `window.ethereum`. Use when asking AI to build or modify a dApp frontend with wallet connect.

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-eip-6963-wallet
```

## Notes

- `conflux-dev/reference-apps.md` contains frontend, wallet, and app integration references for Conflux eSpace.
- `conflux-dev/reference-deploy-verify.md` contains Hardhat, Foundry, and Remix deployment and verification references.
- `conflux-rust-integration-test/assets/` contains test templates and examples.
- `conflux-rust-integration-test/references/` contains detailed testing references.
- `conflux-eip-6963-wallet/reference-patterns.md` contains React + viem + Conflux eSpace wallet discovery patterns.
