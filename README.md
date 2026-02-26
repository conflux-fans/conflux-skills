# conflux-skills

Collection of skills for Conflux-related development.

## Contents

| Skill | Description |
|-------|-------------|
| **conflux-rust-integration-test** | Create or update pytest-based integration tests for conflux-rust (ConfluxTestFramework, fixtures, pytest). |
| **conflux-docs** | Point to official Conflux docs — concepts, eSpace/Core, RPC, deployment. Use when the user asks about Conflux or needs doc links. |
| **conflux-scan-rpc** | Read-only eSpace queries via RPC and ConfluxScan API (tx/receipt, balance, nonce). Analyze tx failure or stuck txs. |
| **conflux-dev** | Build, deploy, verify contracts and integrate apps with Conflux eSpace (Hardhat, Foundry, ConfluxScan verify, Scaffold Conflux). |


## Install

Add one or more skills (replace `<repo-url>` with your repo, e.g. `https://github.com/conflux-fans/conflux-skills`):

```sh
# Integration tests for conflux-rust
npx skills add <repo-url> --skill conflux-rust-integration-test

# Conflux docs helper (concepts + doc URLs)
npx skills add <repo-url> --skill conflux-docs

# Read-only ConfluxScan + eSpace RPC (tx analysis, balances)
npx skills add <repo-url> --skill conflux-scan-rpc

# Build, deploy, verify, integrate (Hardhat, Foundry, ConfluxScan)
npx skills add <repo-url> --skill conflux-dev

```

Example with the conflux-fans repo:

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-rust-integration-test
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-docs
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-scan-rpc
npx skills add https://github.com/conflux-fans/conflux-skills --skill conflux-dev
```
