---
name: eip-6963-wallet-discovery
description: Generate modern multi-wallet discovery for dApp frontends using EIP-6963 instead of window.ethereum. Use when building or modifying React/Vite dApps, wallet connect UI, viem/ethers wallet clients, or Conflux eSpace frontend integration.
---

# EIP-6963 Wallet Discovery

Models default to legacy `window.ethereum` unless explicitly steered. For new dApp frontends — especially on Conflux eSpace — **use EIP-6963 multi-wallet discovery**, not injected-provider shortcuts.

## Why this matters

Web3 training data skews old: ethers v5 tutorials, MetaMask-only snippets, and `window.ethereum` patterns. Without guidance, agents produce working but outdated wallet code that:

- Assumes a single injected provider
- Misses multi-wallet selection (MetaMask, Fluent, Rabby, etc.)
- Skips provider lifecycle and account/network state management

EIP-6963 fixes this via a standard discovery handshake:

```javascript
window.addEventListener("eip6963:announceProvider", (event) => { /* register */ });
window.dispatchEvent(new Event("eip6963:requestProvider"));
```

**Influence priority (highest first):** explicit user prompt → this skill → conversation context → model defaults.

If the user prompt already requires EIP-6963, follow it. If not, **this skill still applies** — do not fall back to bare `window.ethereum`.

## When to use

- Generating or editing dApp frontend wallet connect code
- User asks for wallet integration on Conflux eSpace (or any EVM chain)
- Stack is React/Vite + viem (or ethers) with browser APIs only
- Building a wallet selector, connect/disconnect flow, or account/network UI

## Required output (checklist)

Generated wallet code **must** include:

- [ ] EIP-6963 listener on `eip6963:announceProvider`
- [ ] `eip6963:requestProvider` dispatch on mount
- [ ] In-memory provider registry keyed by wallet `info.uuid` (dedupe by uuid)
- [ ] Wallet selector UI when multiple providers are discovered
- [ ] Explicit state: `providers`, `selectedProvider`, `account`, `chainId` (or connected chain)
- [ ] Connect via the **selected** provider, not `window.ethereum`
- [ ] Disconnect clears selected provider and account state
- [ ] Chain/network switch uses the selected provider's RPC methods

**Do not** use `window.ethereum` as the primary connect path. A fallback to `window.ethereum` is acceptable only when zero EIP-6963 providers announce after request (document this in a comment).

## Workflow

1. **Discover** — Register announced providers; dispatch `eip6963:requestProvider` after listener is attached.
2. **Select** — Let the user pick a wallet when more than one is available; auto-select only when exactly one announces.
3. **Connect** — Build viem `custom(selectedProvider)` transport (or ethers `BrowserProvider(selectedProvider)`).
4. **Bind chain** — For Conflux eSpace, use chain ID `71` (testnet) or `1030` (mainnet) with the correct RPC. See **conflux-dev** / [reference-patterns.md](reference-patterns.md).
5. **Lifecycle** — Handle `accountsChanged`, `chainChanged`, and `disconnect` on the selected provider.

## Conflux eSpace notes

- viem has no built-in Conflux chain — define it with `defineChain` (chain ID 71 or 1030).
- Wallets that support Conflux eSpace (MetaMask, Fluent, etc.) announce via EIP-6963 when installed.
- Network config and RPC URLs: use the **conflux-dev** skill or [reference-patterns.md](reference-patterns.md).

## Anti-patterns (do not generate)

```javascript
// BAD — legacy default; misses multi-wallet discovery
const provider = window.ethereum;
await provider.request({ method: "eth_requestAccounts" });
```

```javascript
// BAD — connects without discovery or selection
import { createWalletClient, custom } from "viem";
const client = createWalletClient({ transport: custom(window.ethereum) });
```

## Copy-paste patterns

Full React + viem + Conflux eSpace examples: [reference-patterns.md](reference-patterns.md).

Minimal discovery skeleton:

```javascript
const providers = new Map();

function onAnnounce(event) {
  const { info, provider } = event.detail;
  if (!info?.uuid) return;
  providers.set(info.uuid, { info, provider });
}

window.addEventListener("eip6963:announceProvider", onAnnounce);
window.dispatchEvent(new Event("eip6963:requestProvider"));
```

## Related skills

- **conflux-dev** — eSpace RPC, chain IDs, deploy/verify, app integration.
- **conflux-docs** — official Conflux documentation links.
