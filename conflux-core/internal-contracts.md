# internal-contracts

Core Space internal contracts guidance for `conflux-core`.

## Usage Defaults

- Set both `CFX_RPC_URL` and `CFX_CHAIN_ID` before any call (see [network-matrix.md](network-matrix.md)).
- `CFX_CHAIN_ID` must match address prefixes: testnet `1` with `cfxtest:`, mainnet `1029` with `cfx:`.
- Code snippets in this file target **Core testnet** (`CFX_CHAIN_ID=1`, `cfxtest:` addresses). For mainnet, swap to the mainnet CIP-37 addresses in the table below and set `CFX_CHAIN_ID=1029`.
- Use `js-conflux-sdk` default entrypoint: `conflux.InternalContract('ContractName')` when the contract is bundled in the SDK.
- Read with `cfx_call` or `.call()`.
- For writes, always follow: `estimate -> user approval -> send`.
- Internal contracts only support `CALL` and `STATICCALL`. `CALLCODE` and `DELEGATECALL` fail by design.

## Internal Contract Address Table

| Contract | hex40 | Mainnet CIP-37 | Testnet CIP-37 |
|----------|-------|----------------|----------------|
| AdminControl | `0x0888000000000000000000000000000000000000` | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2mhjju8k` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaawby2s44d` |
| SponsorWhitelistControl | `0x0888000000000000000000000000000000000001` | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaegg2r16ar` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaeprn7v0eh` |
| Staking | `0x0888000000000000000000000000000000000002` | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajrwuc9jnb` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajh3dw3ctn` |
| ConfluxContext | `0x0888000000000000000000000000000000000004` | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaau5xa6tk73` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaauv2xpkd3x` |
| PoSRegister | `0x0888000000000000000000000000000000000005` | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaayf993ufd7` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaytypk0th1` |
| CrossSpaceCall | `0x0888000000000000000000000000000000000006` | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaa2sn102vjv` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaa2eaeg85p5` |
| ParamsControl | `0x0888000000000000000000000000000000000007` | `cfx:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaa6uhjxh70z` | `cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaa64p5db1w9` |

## Shared Read and Write Flow

Use this baseline flow for all internal contract writes:

1. Build transaction params and calldata.
2. Run `cfx_estimateGasAndCollateral`.
3. Show the risk template in [shared-concepts.md](shared-concepts.md) and wait for explicit user approval.
4. Send transaction.
5. Verify receipt.

Do not send when estimate fails.

If you already have calldata, use `cfx_call` for read-only reproduction before writes:

```bash
cast rpc cfx_call \
  '{"from":"cfxtest:aak2rra2njvd77ezwjvx04kkds9fzagfe6ku8scz91","to":"cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaawby2s44d","data":"0x..."}' \
  latest_state \
  --rpc-url "$CFX_RPC_URL"
```

## AdminControl (with examples)

Official page: <https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/admin>

Supported methods:

- `getAdmin(address contractAddr)` (read)
- `setAdmin(address contractAddr, address newAdmin)` (write)
- `destroy(address contractAddr)` (write, high risk)

`js-conflux-sdk` example:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1), // testnet examples; use 1029 for mainnet
});

const sender = conflux.wallet.addPrivateKey(process.env.CFX_PRIVATE_KEY);
const adminControl = conflux.InternalContract('AdminControl');
const contractAddr = "cfxtest:acepe88unk7fvs18436178up33hb4zkuf62a9dk1gv";
const newAdmin = "cfxtest:aak2rra2njvd77ezwjvx04kkds9fzagfe6ku8scz91";

const currentAdmin = await adminControl.getAdmin(contractAddr).call();
console.log("current admin", currentAdmin);

const setAdminCall = adminControl.setAdmin(contractAddr, newAdmin);
await conflux.cfx.estimateGasAndCollateral({
  from: sender.address,
  to: "cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaawby2s44d",
  value: "0x0",
  data: setAdminCall.data,
});
// Show risk template from shared-concepts.md and wait for user approval before send.
await setAdminCall.sendTransaction({ from: sender }).executed();
```

`destroy` is extremely high risk and disabled after CIP-151 on current networks. Do not include a default executable `destroy` example in this skill.

## SponsorWhitelistControl (with examples)

Official page: <https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/sponsor-whitelist-control>

Typical methods:

- Read: `getSponsorForGas`, `getSponsoredBalanceForGas`, `getSponsoredGasFeeUpperBound`, `isWhitelisted`
- Write (sponsor EOA): `setSponsorForGas`, `setSponsorForCollateral`
- Write (contract admin EOA): `addPrivilegeByAdmin`, `removePrivilegeByAdmin`
- Write (from sponsored contract code): `addPrivilege`, `removePrivilege`

`js-conflux-sdk` example:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1), // testnet examples; use 1029 for mainnet
});

const sender = conflux.wallet.addPrivateKey(process.env.CFX_PRIVATE_KEY);
const sponsor = conflux.InternalContract('SponsorWhitelistControl');
const contractAddr = "cfxtest:acepe88unk7fvs18436178up33hb4zkuf62a9dk1gv";

const upperBound = 10n ** 15n; // Drip
const sponsorValue = 1000n * upperBound; // must be >= 1000 * upperBound
if (sponsorValue < 1000n * upperBound) {
  throw new Error("setSponsorForGas value must be >= 1000 * upperBound");
}

const beforeInfo = await sponsor.getSponsoredGasFeeUpperBound(contractAddr).call();
console.log("before upper bound", beforeInfo.toString());

const setGasCall = sponsor.setSponsorForGas(contractAddr, upperBound);
await conflux.cfx.estimateGasAndCollateral({
  from: sender.address,
  to: "cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaaeprn7v0eh",
  value: `0x${sponsorValue.toString(16)}`,
  data: setGasCall.data,
});
// Show risk template from shared-concepts.md and wait for user approval before send.
await setGasCall.sendTransaction({
  from: sender,
  value: sponsorValue,
}).executed();
```

Sponsor query shortcut:

- Use `cfx_getSponsorInfo` to inspect sponsor-related fields quickly from RPC.

## Staking (with examples)

Official page: <https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/staking>

Supported methods:

- Read: `getStakingBalance`, `getLockedStakingBalance`, `getVotePower`
- Write: `deposit`, `withdraw`, `voteLock`

`js-conflux-sdk` example:

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1), // testnet examples; use 1029 for mainnet
});

const sender = conflux.wallet.addPrivateKey(process.env.CFX_PRIVATE_KEY);
const staking = conflux.InternalContract('Staking');
const minDeposit = 1_000_000_000_000_000_000n; // 1 CFX in Drip (minimum)

const stakingBalance = await staking.getStakingBalance(sender.address).call();
console.log("staking balance", stakingBalance.toString());

const depositCall = staking.deposit(minDeposit);
await conflux.cfx.estimateGasAndCollateral({
  from: sender.address,
  to: "cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaajh3dw3ctn",
  value: "0x0",
  data: depositCall.data,
});
// Show risk template from shared-concepts.md and wait for user approval before send.
await depositCall.sendTransaction({ from: sender }).executed();
```

`voteLock` warning:

- `voteLock(amount, unlockBlockNumber)` creates an irreversible lock promise. Treat it as a one-way action in operation guidance.

## ConfluxContext (with examples)

Official page: <https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/conflux-context>

Supported read methods:

- `epochNumber()`
- `posHeight()`
- `finalizedEpochNumber()`
- `epochHash(uint256 epoch)` (on-chain; not bundled in `js-conflux-sdk` `InternalContract` helper)

`js-conflux-sdk` does not currently export `ConfluxContext` via `InternalContract(...)`. Use `conflux.Contract` with an explicit ABI, or call `cfx_call` directly.

`js-conflux-sdk` read example (testnet):

```js
import { Conflux } from "js-conflux-sdk";

const conflux = new Conflux({
  url: process.env.CFX_RPC_URL,
  networkId: Number(process.env.CFX_CHAIN_ID || 1), // testnet examples; use 1029 for mainnet
});

const contextAddress = "cfxtest:aaejuaaaaaaaaaaaaaaaaaaaaaaaaaaaauv2xpkd3x";
const contextAbi = [
  "function epochNumber() view returns (uint256)",
  "function posHeight() view returns (uint256)",
  "function finalizedEpochNumber() view returns (uint256)",
  "function epochHash(uint256) view returns (bytes32)",
];
const context = conflux.Contract({ abi: contextAbi, address: contextAddress });

const currentEpoch = await context.epochNumber().call();
const posHeight = await context.posHeight().call();
const finalizedEpoch = await context.finalizedEpochNumber().call();
const pivotHash = await context.epochHash(currentEpoch).call();

console.log({ currentEpoch, posHeight, finalizedEpoch, pivotHash });
```

## PoSRegister (method index + official links)

Official page: <https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/poSRegister>

Method index:

- `register`
- `increaseStake`
- `retire`
- `getVotes`
- `identifierToAddress`
- `addressToIdentifier`

## CrossSpaceCall (method index + official links)

Official page: <https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/crossSpaceCall>

Method index:

- `createEVM`
- `transferEVM`
- `callEVM`
- `staticCallEVM`
- `withdrawFromMapped`
- `mappedBalance`
- `mappedNonce`

Cross-space note:

- Call this internal contract through Core Space RPC and Core addresses.
- Semantics target eSpace-side behavior. Keep details in official docs only; do not expand eSpace workflow in this skill.
- Additional bridge doc: <https://doc.confluxnetwork.org/docs/espace/build/cross-space-bridge>

## ParamsControl (method index + official links)

Official page: <https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/params-control>

Method index:

- `castVote`
- `readVote`
- `currentRound`
- `totalVotes`
- `posStakeForVotes`

Reference for parameter voting background: <https://github.com/Conflux-Chain/CIPs/blob/master/CIPs/cip-94.md>

## Troubleshooting

### CALLCODE or DELEGATECALL failure

- Internal contracts reject `CALLCODE` and `DELEGATECALL`. Call them directly with `CALL` / `STATICCALL` via `cfx_call` or `InternalContract(...).call()`.

### Sponsor setup rejected

- `setSponsorForGas` requires `value >= 1000 * upperBound` (both in Drip).
- Confirm the target contract exists on the current network before sponsoring.
- Use `cfx_getSponsorInfo` or `getSponsorForGas` / `isWhitelisted` reads to verify state after send.

### Staking deposit or withdraw failure

- `deposit` minimum is 1 CFX (1e18 Drip). `deposit` is non-payable; funds move from account balance to `stakingBalance`.
- `withdraw` may fail when locked balance promises from `voteLock` are not satisfied.

### Permission or admin errors

- `setAdmin` and `addPrivilegeByAdmin` / `removePrivilegeByAdmin` require the current contract admin.
- `addPrivilege` / `removePrivilege` must be called from the sponsored contract itself, not from an external EOA.
- `AdminControl.destroy` is irreversible; treat failures here as expected guardrails and verify admin ownership first.

### Write failed but cause unclear

- Reproduce with read-only `cfx_call` using the same `from`, `to`, `data`, and `value`.
- Then follow [core-space.md Troubleshooting](core-space.md).

## Related References

- [shared-concepts.md](shared-concepts.md)
- [core-space.md](core-space.md)
- [Core internal contracts overview](https://doc.confluxnetwork.org/docs/core/core-space-basics/internal-contracts/)
