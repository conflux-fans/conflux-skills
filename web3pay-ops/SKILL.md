---
name: web3pay-ops
description: Operate Conflux Web3 Paywall RPC/API key subscriptions, including Confura RPC and ConfluxScan API subscription airdrops, validity checks, and API key claim/signature generation. Use this skill whenever the user mentions RPC key airdrops, Confura or ConfluxScan API key grants, Web3 Paywall subscription airdrops, checking RPC/API key expiration, or generating a Web3 Paywall API key.
metadata: {"requires":{"allBins":["cast","node"]}}
---

# Web3Pay Ops

Use this skill to operate Conflux Web3 Paywall subscription workflows for RPC/API keys on Conflux eSpace mainnet.

Supported operations:

- issue subscription card airdrops
- check a user's subscription validity and expiration time
- claim an API key by signing the Web3 Paywall message

The default chain is Conflux eSpace mainnet. Use `https://evm.confluxrpc.com` unless the user explicitly asks for another RPC endpoint.

## Safety

- Never ask the user to paste a private key into chat.
- Do not store private keys, generated API keys, wallet passwords, recipient lists, or production CSVs inside this skill directory.
- Run `--dry-run` before every airdrop unless the user explicitly says the exact recipients were already checked.
- Before a real airdrop, show the app, app address, card shop, template ID, recipients, and counts, then get explicit user confirmation.
- Use `--confirm` only after the dry run and confirmation; the helper refuses real sends without it.
- Return generated API keys only when the user asked for them, and treat them as sensitive operational material.

## References

Read `references/contracts.md` when you need app aliases, contract addresses, template IDs, function signatures, role details, or the Confura application form link.

Read `references/frontend-data-sources.md` when you need to explain where ConfluxHub payment pages get app names, descriptions, templates, paid-app validity, or API key material.

Known app aliases:

- `confura-rpc`: Confura RPC subscription app
- `confluxscan-api`: ConfluxScan API subscription app

## Helper Script

Prefer the bundled helper script for routine operations:

```bash
./scripts/web3pay-ops.sh apps
./scripts/web3pay-ops.sh app-detail confura-rpc
./scripts/web3pay-ops.sh templates confura-rpc
./scripts/web3pay-ops.sh validity confura-rpc 0xUSER
./scripts/web3pay-ops.sh claim confura-rpc
./scripts/web3pay-ops.sh airdrop confura-rpc 10001 0xUSER=1 --dry-run
./scripts/web3pay-ops.sh airdrop confura-rpc 10001 0xUSER=1 0xUSER2=2 --confirm
./scripts/web3pay-ops.sh airdrop-csv confura-rpc 10001 recipients.csv --dry-run
```

The script defaults to `RPC_URL=https://evm.confluxrpc.com`.

## Wallet Handling

For write operations and API key claim signing, recommend a runtime wallet option instead of storing credentials in the skill:

```bash
export WALLET_MODE=interactive
```

or:

```bash
export WALLET_MODE=browser
```

or, when the user has a secure local environment and explicitly chooses it:

```bash
export PRIVATE_KEY=0x...
```

The helper passes wallet material to `cast` only at execution time. It also supports Foundry keystore variables such as `ETH_KEYSTORE`, `ETH_KEYSTORE_ACCOUNT`, `ETH_PASSWORD`, and `ETH_PASSWORD_FILE`.

For an intentionally empty keystore password, set `ETH_PASSWORD=` explicitly:

```bash
ETH_KEYSTORE_ACCOUNT=rpc-airdrop-operator ETH_PASSWORD= ./scripts/web3pay-ops.sh airdrop confura-rpc 10001 0xUSER=1 --confirm
```

## Airdrop Workflow

1. Identify the target app alias or app address.
2. Run `./scripts/web3pay-ops.sh templates <app>` and confirm the intended template ID.
3. Read the template summary from `references/contracts.md`, including known tier meaning and unknowns.
4. Check `AIRDROP_ROLE` before airdrops from a new sender:

```bash
./scripts/web3pay-ops.sh role-check confura-rpc 0xSENDER
```

5. For one or a few recipients, pass direct `address=count` arguments:

```bash
./scripts/web3pay-ops.sh airdrop confura-rpc 10001 0x1111111111111111111111111111111111111111=1 --dry-run
```

6. For larger batches, prepare a CSV with this format:

```csv
address,count
0x1111111111111111111111111111111111111111,1
0x2222222222222222222222222222222222222222,2
```

7. Run a dry run first:

```bash
./scripts/web3pay-ops.sh airdrop confura-rpc 10001 0x1111111111111111111111111111111111111111=1 --dry-run
./scripts/web3pay-ops.sh airdrop-csv confura-rpc 10001 recipients.csv --dry-run
```

8. Confirm that the resolved app, card shop, receivers, counts, and template ID match the request.
9. Execute with `--confirm` only after explicit confirmation.
10. Save the transaction hash in the task notes or response.
11. Query at least one recipient's validity to confirm the result.

The chain call is:

```text
CardShop.giveCardBatch(address[] receiverArr, uint256[] countArr, uint256 templateId)
```

The sender must have `AIRDROP_ROLE` on the app.

## Claim Workflow

Claiming means generating the user's Web3 Paywall API key. It is not a chain transaction.

The frontend signs:

```json
{"domain":"web3pay","contract":"<app address>"}
```

Then it base58-encodes the signature bytes. Use:

```bash
./scripts/web3pay-ops.sh claim confura-rpc
```

Return only the generated API key when the user asked for it.

## Validity Query Workflow

Use:

```bash
./scripts/web3pay-ops.sh validity confura-rpc 0xUSER
```

The script reads:

```text
CardTracker.getVipInfo(address account) returns (expireAt, props, name)
```

Report:

- whether `expireAt` is zero, expired, or active
- the exact Unix timestamp
- the local rendered date shown by the script
- the subscription name and tier props when present

## Related Skills

- `conflux-scan-rpc`: use for read-only Conflux eSpace transaction, balance, receipt, and contract-state inspection outside the Web3 Paywall workflow.
- Check `SKILL_LIST.md` for GitHub URLs and install commands for related Conflux skills.
