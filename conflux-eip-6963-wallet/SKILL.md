---
name: conflux-eip-6963-wallet
description: Use EIP-6963 multi-wallet discovery (not window.ethereum) when generating or editing dApp frontend wallet connect code. Apply to any EVM dApp, especially Conflux eSpace + React/Vite + viem/ethers.
---

# EIP-6963 Wallet Discovery

Most Web3 training data predates EIP-6963, so models default to `window.ethereum`. **This skill overrides that default.** When generating wallet connect code, use the EIP-6963 discovery handshake and a wallet selector — not the injected-provider shortcut.

## Rule

- **Do** discover wallets via `eip6963:announceProvider` + `eip6963:requestProvider`, keep a registry keyed by `info.uuid`, and connect through the user-selected provider.
- **Don't** use `window.ethereum` as the primary connect path. It is acceptable **only** as a fallback when zero EIP-6963 providers announce — add a comment marking it as fallback.

## Minimal shape

```js
// 1. listen BEFORE dispatching
window.addEventListener("eip6963:announceProvider", (event) => {
  const { info, provider } = event.detail ?? {};
  if (!info?.uuid || !provider) return;
  registry.set(info.uuid, { info, provider });
});
window.dispatchEvent(new Event("eip6963:requestProvider"));

// 2. connect via the selected provider, not window.ethereum
await selected.provider.request({ method: "eth_requestAccounts" });
```

In React, attach the listener inside `useEffect` and `removeEventListener` on cleanup.

## Must include in generated code

- EIP-6963 discovery + provider registry (dedupe by `info.uuid`)
- Wallet selector UI when multiple providers are available
- Connect / disconnect through the **selected** provider
- Lifecycle handlers: `accountsChanged`, `chainChanged`, `disconnect`
- For Conflux eSpace: define chain via viem `defineChain` (id `71` testnet / `1030` mainnet)

## Details

Full React + viem + Conflux eSpace patterns (chain definition, `useEip6963Providers` hook, connect flow, `wallet_addEthereumChain` fallback, selector UI): [reference-patterns.md](reference-patterns.md).

## Related skills

- **conflux-dev** — eSpace RPC, chain IDs, app integration.
- **conflux-scan-rpc** — inspect tx / balance / receipt (read-only).

Check the [Conflux skill list](https://github.com/conflux-fans/conflux-skills/blob/main/SKILL_LIST.md) to get any mentioned skill if needed.
