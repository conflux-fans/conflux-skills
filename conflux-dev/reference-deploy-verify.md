# Conflux eSpace – Deploy and verify reference

## Hardhat

### Network config

```javascript
// hardhat.config.js / hardhat.config.ts
module.exports = {
  networks: {
    eSpaceTestnet: {
      url: "https://evmtestnet.confluxrpc.com",
      chainId: 71,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
    eSpaceMainnet: {
      url: "https://evm.confluxrpc.com",
      chainId: 1030,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: {
    apiKey: {
      eSpaceTestnet: "espace",  // or any placeholder
      eSpaceMainnet: "espace",
    },
    customChains: [
      {
        network: "eSpaceTestnet",
        chainId: 71,
        urls: {
          apiURL: "https://evmapi-testnet.confluxscan.org/api/",
          browserURL: "https://evmtestnet.confluxscan.org/",
        },
      },
      {
        network: "eSpaceMainnet",
        chainId: 1030,
        urls: {
          apiURL: "https://evmapi.confluxscan.org/api/",
          browserURL: "https://evm.confluxscan.org/",
        },
      },
    ],
  },
};
```

### Verify

```bash
npx hardhat verify --network eSpaceTestnet <CONTRACT_ADDRESS> [constructor arg1 arg2 ...]
```

If constructor has no args, omit the trailing arguments.

## Foundry

### Deploy

```bash
# Testnet
forge create src/MyContract.sol:MyContract \
  --rpc-url https://evmtestnet.confluxrpc.com \
  --private-key $PRIVATE_KEY

# Mainnet
forge create src/MyContract.sol:MyContract \
  --rpc-url https://evm.confluxrpc.com \
  --private-key $PRIVATE_KEY
```

### Verify

Do **not** pass `--chain-id`. Use ConfluxScan verifier URL:

```bash
# Testnet
forge verify-contract <CONTRACT_ADDRESS> MyContract \
  --verifier-url https://evmapi-testnet.confluxscan.org/api/ \
  --etherscan-api-key any

# With constructor args (ABI-encoded)
forge verify-contract <CONTRACT_ADDRESS> MyContract \
  --verifier-url https://evmapi-testnet.confluxscan.org/api/ \
  --etherscan-api-key any \
  --constructor-args $(cast abi-encode "constructor(uint256)" 42)
```

Mainnet: use `https://evmapi.confluxscan.org/api/` as `--verifier-url`.

## Remix

1. MetaMask: add Conflux eSpace Testnet (chain ID 71, RPC https://evmtestnet.confluxrpc.com, explorer https://evmtestnet.confluxscan.org).
2. In Remix, "Deploy and Run" → Environment: "Injected Provider - MetaMask".
3. Select Conflux eSpace Testnet and deploy.

Doc: https://doc.confluxnetwork.org/docs/espace/tutorials/deployContract/remix

## Gotchas

- **Foundry verify:** Do **not** pass `--chain-id`; ConfluxScan verification ignores it and it can break the request. Use only `--verifier-url` and `--etherscan-api-key`.
- **Verification failures:** Compiler version and optimization settings must match the deployment. If verification fails, confirm solc version and `optimizer.runs` (or equivalent) match what was used when deploying. See [Verify contracts](https://doc.confluxnetwork.org/docs/espace/tutorials/VerifyContracts).
