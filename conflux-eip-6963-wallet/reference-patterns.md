# EIP-6963 + viem patterns (Conflux eSpace)

Reference implementations for AI-generated dApp wallet code. Prefer viem + browser APIs; do not import wagmi unless the project already includes it.

## Conflux eSpace chain definitions

```javascript
import { defineChain } from "viem";

export const confluxESpaceTestnet = defineChain({
  id: 71,
  name: "Conflux eSpace Testnet",
  nativeCurrency: { symbol: "CFX", decimals: 18 },
  rpcUrls: {
    default: { http: ["https://evmtestnet.confluxrpc.com"] },
  },
  blockExplorers: {
    default: { name: "ConfluxScan", url: "https://evmtestnet.confluxscan.org" },
  },
});

export const confluxESpaceMainnet = defineChain({
  id: 1030,
  name: "Conflux eSpace",
  nativeCurrency: { symbol: "CFX", decimals: 18 },
  rpcUrls: {
    default: { http: ["https://evm.confluxrpc.com"] },
  },
  blockExplorers: {
    default: { name: "ConfluxScan", url: "https://evm.confluxscan.org" },
  },
});
```

## Provider registry hook (React)

```javascript
import { useEffect, useState } from "react";

export function useEip6963Providers() {
  const [providers, setProviders] = useState([]);

  useEffect(() => {
    const map = new Map();

    function onAnnounce(event) {
      const { info, provider } = event.detail ?? {};
      if (!info?.uuid || !provider) return;
      map.set(info.uuid, { info, provider });
      setProviders(Array.from(map.values()));
    }

    window.addEventListener("eip6963:announceProvider", onAnnounce);
    window.dispatchEvent(new Event("eip6963:requestProvider"));

    return () => window.removeEventListener("eip6963:announceProvider", onAnnounce);
  }, []);

  return providers;
}
```

## Connect with selected provider (viem)

```javascript
import { createWalletClient, custom } from "viem";
import { confluxESpaceTestnet } from "./chains";

export async function connectWallet(selectedProvider, targetChain = confluxESpaceTestnet) {
  const accounts = await selectedProvider.request({
    method: "eth_requestAccounts",
  });

  const chainIdHex = await selectedProvider.request({ method: "eth_chainId" });
  const chainId = Number(chainIdHex);

  if (chainId !== targetChain.id) {
    try {
      await selectedProvider.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: `0x${targetChain.id.toString(16)}` }],
      });
    } catch (err) {
      // 4902 = chain not added in wallet; add it then retry switch.
      // See "wallet_addEthereumChain params" below for the params object.
      if (err?.code === 4902) {
        await selectedProvider.request({
          method: "wallet_addEthereumChain",
          params: [buildAddChainParams(targetChain)],
        });
        await selectedProvider.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: `0x${targetChain.id.toString(16)}` }],
        });
      } else {
        throw err;
      }
    }
  }

  const walletClient = createWalletClient({
    chain: targetChain,
    transport: custom(selectedProvider),
    account: accounts[0],
  });

  return { walletClient, account: accounts[0], chainId: targetChain.id };
}
```

## Provider lifecycle listeners

Attach after connect; remove on disconnect or unmount.

```javascript
function bindProviderEvents(provider, { onAccountsChanged, onChainChanged, onDisconnect }) {
  provider.on?.("accountsChanged", onAccountsChanged);
  provider.on?.("chainChanged", onChainChanged);
  provider.on?.("disconnect", onDisconnect);

  return () => {
    provider.removeListener?.("accountsChanged", onAccountsChanged);
    provider.removeListener?.("chainChanged", onChainChanged);
    provider.removeListener?.("disconnect", onDisconnect);
  };
}
```

## Wallet selector UI (minimal)

```jsx
function WalletSelector({ providers, onSelect }) {
  if (providers.length === 0) {
    return <p>No EIP-6963 wallets detected. Install MetaMask or another compatible wallet.</p>;
  }

  return (
    <ul>
      {providers.map(({ info, provider }) => (
        <li key={info.uuid}>
          <button type="button" onClick={() => onSelect({ info, provider })}>
            {info.icon && <img src={info.icon} alt="" width={24} height={24} />}
            {info.name}
          </button>
        </li>
      ))}
    </ul>
  );
}
```

## wallet_addEthereumChain params

Provide this object to `wallet_addEthereumChain` (used by `connectWallet` above when switch fails with error 4902):

```javascript
function buildAddChainParams(chain) {
  const params = {
    chainId: `0x${chain.id.toString(16)}`, // 71 → "0x47", 1030 → "0x406"
    chainName: chain.name,
    nativeCurrency: { name: "CFX", symbol: "CFX", decimals: 18 },
    rpcUrls: chain.rpcUrls.default.http,
  };

  const explorerUrl = chain.blockExplorers?.default?.url;
  if (explorerUrl) params.blockExplorerUrls = [explorerUrl];

  return params;
}
```

## Expected outcome vs legacy default

| Signal | With this skill | Without (model default) |
|--------|-----------------|-------------------------|
| Discovery | `eip6963:announceProvider` + registry | `window.ethereum` only |
| Multi-wallet | Selector when >1 wallet | Single injected provider |
| State | provider + account + chain tracked | Minimal connect button |
| Lifecycle | `accountsChanged` / `chainChanged` | Often missing |

Validated across GPT, Claude, and DeepSeek dApp generation: adding this skill consistently shifts output from `window.ethereum` to EIP-6963 patterns when no explicit prompt override is given.
