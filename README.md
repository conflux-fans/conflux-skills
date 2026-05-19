# conflux-skills

Small collection of reusable Codex skills for Conflux-related development workflows.

## Project structure

```text
.
├── README.md
├── confura/
│   ├── SKILL.md
│   ├── reference-ai-tasks.md
│   ├── reference-components.md
│   ├── reference-deploy-ops.md
│   ├── reference-getlogs-dynamic-bounds.md
│   ├── reference-getlogs-suggestion.md
│   ├── reference-getlogs-trace.md
│   ├── reference-rate-limit-diagnostics.md
│   └── reference-rpc-usage.md
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
```

## Available skills

### confura

Use, document, develop, deploy, and troubleshoot Confura, the Conflux public RPC gateway, including endpoint selection, `cfx_*`/`eth_*` RPC usage, `getLogs` dynamic query bounds, rate-limit diagnostics, API-key usage, and Confura operator workflows.

```sh
npx skills add https://github.com/conflux-fans/conflux-skills --skill confura
```

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

## Notes

- `confura/reference-rpc-usage.md` contains public RPC endpoint selection and ordinary JSON-RPC examples.
- `confura/reference-getlogs-dynamic-bounds.md`, `confura/reference-getlogs-suggestion.md`, and `confura/reference-getlogs-trace.md` describe Confura-specific `getLogs` behavior.
- `confura/reference-rate-limit-diagnostics.md` covers throttling, quota, API-key, and diagnostic workflows.
- `confura/reference-components.md`, `confura/reference-deploy-ops.md`, and `confura/reference-ai-tasks.md` cover architecture, operations, and Confura development guidance.
- `conflux-dev/reference-apps.md` contains frontend, wallet, and app integration references for Conflux eSpace.
- `conflux-dev/reference-deploy-verify.md` contains Hardhat, Foundry, and Remix deployment and verification references.
- `conflux-rust-integration-test/assets/` contains test templates and examples.
- `conflux-rust-integration-test/references/` contains detailed testing references.
