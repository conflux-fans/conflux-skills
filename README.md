# conflux-skills

Small collection of reusable Codex skills for Conflux-related development workflows.

## Project structure

```text
.
├── README.md
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

- `conflux-rust-integration-test/assets/` contains test templates and examples.
- `conflux-rust-integration-test/references/` contains detailed testing references.
