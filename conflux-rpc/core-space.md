# core-space

Core Space RPC guidance for read and write workflows.

## Read Operations

Use `js-conflux-sdk` as the default path. Use `cast rpc cfx_*` as a quick direct RPC comparison path when needed.

### Balance (`cfx_getBalance`)

`js-conflux-sdk`:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1029),
});

const address = "cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg";
const balance = await conflux.cfx.getBalance(address, "latest_state");
console.log(balance.toString());
```

`cast rpc`:

```bash
cast rpc cfx_getBalance \
  cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg \
  latest_state \
  --rpc-url "$CFX_RPC_URL"
```

### Account (`cfx_getAccount`)

`js-conflux-sdk`:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({ url: process.env.CFX_RPC_URL });
const address = "cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg";
const account = await conflux.cfx.getAccount(address, "latest_state");
console.log(account);
```

`cast rpc`:

```bash
cast rpc cfx_getAccount \
  cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg \
  latest_state \
  --rpc-url "$CFX_RPC_URL"
```

### State (`cfx_getStatus`)

`js-conflux-sdk`:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({ url: process.env.CFX_RPC_URL });
const status = await conflux.cfx.getStatus();
console.log(status);
```

`cast rpc`:

```bash
cast rpc cfx_getStatus --rpc-url "$CFX_RPC_URL"
```

### Call (`cfx_call`)

`js-conflux-sdk`:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({ url: process.env.CFX_RPC_URL });

const result = await conflux.cfx.call(
  {
    from: "cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg",
    to: "cfx:acckucyy5fhz5m3h0j6b6w5swk0m2a0df6u4k8f5kx",
    data: "0x06fdde03",
  },
  "latest_state",
);

console.log(result);
```

`cast rpc`:

```bash
cast rpc cfx_call \
  '{"from":"cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg","to":"cfx:acckucyy5fhz5m3h0j6b6w5swk0m2a0df6u4k8f5kx","data":"0x06fdde03"}' \
  latest_state \
  --rpc-url "$CFX_RPC_URL"
```

### Tx / Receipt (`cfx_getTransactionByHash`, `cfx_getTransactionReceipt`)

`js-conflux-sdk`:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({ url: process.env.CFX_RPC_URL });
const txHash = "0xYOUR_TX_HASH";

const tx = await conflux.cfx.getTransactionByHash(txHash);
const receipt = await conflux.cfx.getTransactionReceipt(txHash);

console.log({ tx, receipt });
```

`cast rpc`:

```bash
cast rpc cfx_getTransactionByHash 0xYOUR_TX_HASH --rpc-url "$CFX_RPC_URL"
cast rpc cfx_getTransactionReceipt 0xYOUR_TX_HASH --rpc-url "$CFX_RPC_URL"
```

## Write Operations

Mandatory sequence for Core Space writes:

1. build params
2. `cfx_estimateGasAndCollateral`
3. network/sender check
4. send tx
5. receipt verify

**Never send transaction without successful estimation. 未估算不得发送。**

### Reference Flow

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1029),
});

const sender = conflux.wallet.addPrivateKey(process.env.CFX_PRIVATE_KEY);
const senderAddress = sender.address;

// 1) build params
const txParams = {
  from: senderAddress,
  to: "cfx:acckucyy5fhz5m3h0j6b6w5swk0m2a0df6u4k8f5kx",
  value: "0x0",
  data: "0x",
};

// 2) estimate first (required)
const estimation = await conflux.cfx.estimateGasAndCollateral(txParams);
if (!estimation || !estimation.gasLimit || !estimation.storageCollateralized) {
  throw new Error("cfx_estimateGasAndCollateral failed; stop sending.");
}

// 3) network/sender check
const expectedChainId = Number(process.env.CFX_CHAIN_ID || 1029);
const [status, nextNonce] = await Promise.all([
  conflux.cfx.getStatus(),
  conflux.cfx.getNextNonce(senderAddress),
]);

if (status.chainId !== expectedChainId) {
  throw new Error(`Network mismatch: ${status.chainId}`);
}

// 4) send tx
const pending = conflux.cfx.sendTransaction({
  ...txParams,
  gas: estimation.gasLimit,
  storageLimit: estimation.storageCollateralized,
  nonce: nextNonce,
});
const txHash = await pending;
console.log("sent", txHash);

// 5) receipt verify
const receipt = await pending.confirmed();
if (!receipt || receipt.outcomeStatus !== 0) {
  throw new Error(`Transaction failed, receipt outcomeStatus=${receipt?.outcomeStatus}`);
}
console.log("confirmed", receipt);
```

Quick `cast rpc` checks:

`cast rpc` is suitable for RPC inspection and read/call verification. Do not treat `cast` as a full Core Space raw transaction flow (build + sign + send + confirm). For signed sending, follow `js-conflux-sdk` or native Core Space signing workflow and then use `cfx_sendRawTransaction`.

```bash
cast rpc cfx_estimateGasAndCollateral \
  '{"from":"cfx:...","to":"cfx:...","value":"0x0","data":"0x"}' \
  --rpc-url "$CFX_RPC_URL"

cast rpc cfx_sendRawTransaction 0xSIGNED_RAW_TX --rpc-url "$CFX_RPC_URL"
cast rpc cfx_getTransactionReceipt 0xYOUR_TX_HASH --rpc-url "$CFX_RPC_URL"
```

Mainnet write risk warning:

- Mainnet writes are irreversible and may consume real CFX (gas + storage collateral).
- Run the same flow on testnet first and verify `to`, `data`, `value`, nonce, and chain ID before mainnet execution.

## Troubleshooting

### send failed immediately

- Validate `from` is unlocked/signed correctly and belongs to current key.
- Re-run `cfx_estimateGasAndCollateral`; if it fails, fix reason before any resend.
- Confirm RPC endpoint and chain/network are expected (mainnet vs testnet).
- Verify address format and method calldata.

### transaction stuck (nonce/pending)

- Query `cfx_getNextNonce` and compare with tx nonce.
- Check pending pool state with `cfx_getTransactionByHash`.
- If nonce gap exists, send missing nonce transaction first.
- If duplicate nonce exists, replace with higher fee strategy where applicable.

### insufficient collateral

- `cfx_estimateGasAndCollateral` result includes required storage collateral.
- Ensure sender has enough CFX for both gas and storage collateral.
- Reduce storage impact or contract write scope if collateral is too high.

### epoch parameter mismatch

- Read methods should use consistent epoch tags (`latest_state`, `latest_mined`, etc.).
- If using block-specific epochs, ensure referenced epoch is available on current node.
- Do not mix assumptions from one epoch tag with data queried from another tag.
