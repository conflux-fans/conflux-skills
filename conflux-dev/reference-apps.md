# Conflux eSpace – App integration reference

## RPC and chain ID

- **Testnet:** RPC `https://evmtestnet.confluxrpc.com`, chain ID `71`
- **Mainnet:** RPC `https://evm.confluxrpc.com`, chain ID `1030`

## ethers.js

```javascript
import { ethers } from "ethers";

const provider = new ethers.JsonRpcProvider("https://evmtestnet.confluxrpc.com");
// Or mainnet: "https://evm.confluxrpc.com"
// Chain ID 71 (testnet) or 1030 (mainnet)
```

## viem

viem has **no built-in Conflux chain**. Define a custom chain:

```javascript
import { createPublicClient, http, defineChain } from "viem";

const confluxESpaceTestnet = defineChain({
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

const confluxESpaceMainnet = defineChain({
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

const client = createPublicClient({
  chain: confluxESpaceTestnet,
  transport: http(),
});
```

## Scaffold Conflux

Scaffold Conflux is an adaptation of Scaffold-ETH-2 for Conflux.

- Repo/tutorial: https://doc.confluxnetwork.org/docs/espace/tutorials/scaffoldCfx/scaffold
- Deploy: `yarn deploy --network confluxESpace` (or confluxESpaceTestnet if configured)
- Frontend: set `targetNetworks: [chains.confluxESpace]` in scaffold config so wallet connects to Conflux eSpace

## Wallet (MetaMask)

1. Add network: Conflux eSpace Testnet — RPC https://evmtestnet.confluxrpc.com, chain ID 71, symbol CFX, block explorer https://evmtestnet.confluxscan.org
2. Mainnet: RPC https://evm.confluxrpc.com, chain ID 1030, explorer https://evm.confluxscan.org

User guide: https://doc.confluxnetwork.org/docs/espace/UserGuide

## Testnet faucet

Get testnet CFX for deployment and txs: https://efaucet.confluxnetwork.org/

## Cross-space (optional)

To bridge CFX from Core Space to eSpace: https://doc.confluxnetwork.org/docs/general/tutorials/transferring-funds/transfer-funds-across-spaces
