# Web3 Paywall RPC Key Airdrop Contracts

Network: Conflux eSpace mainnet

Default RPC:

```text
https://evm.confluxrpc.com
```

## Apps

### Confura RPC

Alias: `confura-rpc`

App:

```text
0x33A9451ee070d750a077C93f71D2cFcD0180Fa7D
```

Application form:

```text
https://forms.office.com/r/BTe8Y3PUER
```

CardShop:

```text
0x8be2123e35CF39C6FAbB0d5Ed2dcc074c11F7407
```

CardTemplate:

```text
0x62Ba85BDB737d2d814D44a26B14fee1De1817069
```

CardTracker:

```text
0x5154a68fe1fdAeB6A9B17Dee055BEF13B0401cA4
```

Known templates:

| ID | Name | Duration | Tier |
| --- | --- | --- | --- |
| 10001 | Standard/month | 2592000 seconds | 1 |
| 10002 | Professional/month | 2592000 seconds | 2 |
| 10003 | Pro Plus/month | 2592000 seconds | 3 |
| 10004 | Standard/day | 86400 seconds | 1 |

Operational meaning:

| ID | Meaning |
| --- | --- |
| 10001 | Standard tier for one month. Public docs identify Standard as 100 QPS overall, 1,000,000 calls/day, with method-specific limits such as `eth_call` 50 QPS and `eth_getLogs` 20 QPS. |
| 10002 | Professional tier for one month. Chain template marks it as tier `2`; exact backend rate limits are not published in the referenced docs. Confirm intended use before issuing. |
| 10003 | Pro Plus tier for one month. Chain template marks it as tier `3`; exact backend rate limits are not published in the referenced docs. Confirm intended use before issuing. |
| 10004 | Standard tier for one day. Same tier marker as Standard/month, shorter duration. |

### ConfluxScan API

Alias: `confluxscan-api`

App:

```text
0x7f55828e334e63065b88055776db3a58734220ad
```

CardShop:

```text
0xb816CBF6Fc07e8884FA3c3f6184C3395c95DB8B6
```

CardTemplate:

```text
0x7C9e21a1D844DBe2b289dE39C93cb124336307c9
```

CardTracker:

```text
0x7F21892d29fa9b03b512e87EFAC0BcF7Ac42Ea63
```

Known templates:

| ID | Name | Duration | Tier |
| --- | --- | --- | --- |
| 10001 | Standard/month | 2592000 seconds | Standard tier |

Operational meaning:

| ID | Meaning |
| --- | --- |
| 10001 | Standard tier for one month. Chain template marks this as `Tier1 = Standard tier`; exact backend rate limits are not published in the referenced docs. Confirm intended use before issuing. |

## Confirmation Policy

Before any real airdrop send, present this information and get explicit user confirmation:

- app alias and app address
- card shop address
- template ID, name, duration, and known tier meaning
- recipient addresses and counts
- whether any tier meaning is inferred only from chain template metadata

The helper script enforces this mechanically: real airdrops require `--confirm`; otherwise use `--dry-run`.

## Function Signatures

Issue subscription airdrop:

```text
giveCardBatch(address[],uint256[],uint256)
```

List templates:

```text
list(uint256,uint256)((uint256,string,string,uint256,uint256,uint256,(string[],string[]))[],uint256)
```

Get app card shop:

```text
cardShop()(address)
```

Get app public details:

```text
link()(string)
description()(string)
paymentType()(uint8)
getVipCoin()(address)
```

Get VIP coin display fields:

```text
name()(string)
symbol()(string)
```

Get card shop template:

```text
template()(address)
```

Get card shop tracker:

```text
tracker()(address)
```

Get user subscription validity:

```text
getVipInfo(address)((uint256,(string[],string[]),string))
```

Check airdrop role:

```text
hasRole(bytes32,address)(bool)
```

`AIRDROP_ROLE`:

```text
0x3a2f235c9daaf33349d300aadff2f15078a89df81bcfdd45ba11c8f816bddc6f
```

Claim API key message:

```json
{"domain":"web3pay","contract":"<app address>"}
```

The API key is `base58(signature bytes)`.
