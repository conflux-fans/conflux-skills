# core-space

Core Space RPC guidance for read and write workflows.

## Read Operations

Set both `CFX_RPC_URL` and `CFX_CHAIN_ID` to match the target network (see [network-matrix.md](network-matrix.md)). Do not rely on RPC URL alone.

Code snippets in this file default to **Core mainnet** (`CFX_CHAIN_ID=1029`, `cfx:` addresses). For testnet, use `CFX_CHAIN_ID=1`, `cfxtest:` addresses, and a testnet RPC from [network-matrix.md](network-matrix.md). [internal-contracts.md](internal-contracts.md) examples target testnet instead — follow that file's Usage Defaults when copying internal-contract snippets.

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

`curl` JSON-RPC fallback:

```bash
curl -s -X POST "$CFX_RPC_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "cfx_getBalance",
    "params": [
      "cfx:aarc9abycue0hhzgyrr53m6cxedgccrmmyybjgh4xg",
      "latest_state"
    ]
  }'
```

### Account (`cfx_getAccount`)

`js-conflux-sdk`:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1029),
});
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

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1029),
});
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

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1029),
});

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

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1029),
});
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
4. show the write risk template from [shared-concepts.md](shared-concepts.md) (mainnet template for mainnet; testnet confirmation wording for testnet) and wait for explicit user approval
5. send tx
6. receipt verify

**Never send a transaction without a successful `cfx_estimateGasAndCollateral` preflight.**

Mainnet write risk warning (read before any send example):

- Mainnet writes are irreversible and may consume real CFX (gas + storage collateral).
- Before mainnet execution, verify `to`, `data`, `value`, nonce, and chain ID on the **target mainnet** endpoint. Do not assume a testnet rehearsal covers contract calls — mainnet and testnet contracts often differ, and a mainnet contract may not exist on testnet.
- For simple native CFX transfers only, an optional testnet dry run can help validate the send flow; for contract writes, confirm the contract exists on mainnet (for example via `cfx_getCode`) instead of relying on testnet parity.
- Show the write risk template from [shared-concepts.md](shared-concepts.md) and wait for explicit user approval before calling `sendTransaction`.

### Reference Flow

Minimal native transfer / empty-call example (`value` + `data: "0x"`). Contract writes use the same sequence; only `txParams` construction changes (see below).

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
if (!estimation || estimation.gasUsed == null || estimation.storageCollateralized == null) {
  throw new Error("cfx_estimateGasAndCollateral failed; stop sending.");
}
// storageCollateralized may be 0 for simple CFX transfers; that is valid.

// 3) network/sender check
const expectedChainId = Number(process.env.CFX_CHAIN_ID || 1029);
const [status, nextNonce] = await Promise.all([
  conflux.cfx.getStatus(),
  conflux.cfx.getNextNonce(senderAddress),
]);

if (status.chainId !== expectedChainId) {
  throw new Error(`Network mismatch: ${status.chainId}`);
}

// 4) user approval gate (required before send)
// Show the write risk template from shared-concepts.md (mainnet vs testnet wording) and wait for explicit approval.
// Do not call sendTransaction until the user confirms.

// 5) send tx
// Omit gas and storageLimit so js-conflux-sdk auto-fills from its internal estimate.
// Preflight estimation above is still required for validation and user review.
const pending = conflux.cfx.sendTransaction({
  ...txParams,
  nonce: nextNonce,
});
const txHash = await pending;
console.log("sent", txHash);

// 6) receipt verify
const receipt = await pending.confirmed();
if (!receipt || receipt.outcomeStatus !== 0) {
  throw new Error(`Transaction failed, receipt outcomeStatus=${receipt?.outcomeStatus}`);
}
console.log("confirmed", receipt);
```

### Contract Write (`data` with calldata)

Use the same mandatory sequence as above. For contract calls, set `to` to the contract address and `data` to the encoded function call. Prefer a read-only `cfx_call` with the same `to`/`data`/`from` first to catch revert reasons before sending.

**Option A — `js-conflux-sdk` Contract helper (recommended when ABI is known):**

```js
const contract = conflux.Contract({ abi, address: contractAddress });

// Read-only check first (same params as the write)
await contract.myMethod(arg1, arg2).call({ from: senderAddress });

// Write: SDK builds calldata and follows the same estimate → approve → send flow
const pending = contract.myMethod(arg1, arg2).sendTransaction({ from: senderAddress });
const txHash = await pending;
const receipt = await pending.confirmed();
```

Still run `cfx_estimateGasAndCollateral` on the built transaction params before send when you need to show gas/collateral to the user or when not using the Contract helper's built-in estimate path.

**Option B — manual `txParams` (when you already have calldata):**

```js
const txParams = {
  from: senderAddress,
  to: contractAddress,           // cfx:... or cfxtest:...
  value: "0x0",                  // set non-zero for payable functions
  data: "0x70a08231" + paddedArgs, // 4-byte selector + ABI-encoded arguments
};

const estimation = await conflux.cfx.estimateGasAndCollateral(txParams);
// ...same network check, user approval, send, receipt verify as Reference Flow
```

Calldata sources:

- `contract.methodName(args).data` from `js-conflux-sdk` Contract
- ABI encode offline (Foundry `cast calldata`, etc.) then paste into `data`
- Reuse the `data` field from a successful read-only `cfx_call` in the Read Operations section

Contract-write checks before send:

- Confirm contract bytecode exists on the target network (`cfx_getCode` not empty).
- For payable calls, set `value` and include it in estimation.
- Expect non-zero `storageCollateralized` when the call writes storage; zero collateral alone does not mean failure.

Quick `cast rpc` checks:

`cast rpc` is suitable for RPC inspection and read/call verification. Do not treat `cast` as a full Core Space raw transaction flow (build + sign + send + confirm). For signed sending, follow `js-conflux-sdk` or native Core Space signing workflow and then use `cfx_sendRawTransaction`.

```bash
cast rpc cfx_estimateGasAndCollateral \
  '{"from":"cfx:...","to":"cfx:...","value":"0x0","data":"0x"}' \
  --rpc-url "$CFX_RPC_URL"

cast rpc cfx_sendRawTransaction 0xSIGNED_RAW_TX --rpc-url "$CFX_RPC_URL"
cast rpc cfx_getTransactionReceipt 0xYOUR_TX_HASH --rpc-url "$CFX_RPC_URL"
```

For Core internal contracts (`AdminControl`, `SponsorWhitelistControl`, `Staking`, and others), reuse the same estimate -> approval -> send sequence in this section.
Use [internal-contracts.md](internal-contracts.md) for canonical addresses, internal-contract method indexes, and copy-paste-safe examples.
Keep CrossSpaceCall interactions on Core RPC while following its eSpace-targeted semantics from the official reference.

## Troubleshooting

### send failed immediately

- Validate `from` is unlocked/signed correctly and belongs to current key.
- Re-run `cfx_estimateGasAndCollateral`; if it fails, fix reason before any resend.
- Confirm RPC endpoint and chain/network are expected (mainnet vs testnet).
- Verify address format and method calldata.

### execution failed (receipt available)

- Read `receipt.txExecErrorMsg` when `outcomeStatus !== 0`; this field often explains Core execution failure.
- Compare `gasUsed` and `storageLimit` against estimation if failure looks resource-related.

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
