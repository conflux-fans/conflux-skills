# ConfluxHub Payment Page Data Sources

This reference records where the ConfluxHub payment frontend gets the app-related text and subscription data shown on pages such as:

```text
https://v1.confluxhub.io/payment/consumer/app/subscription/<app>
```

The page is a static React app. The app information displayed in the payment UI is read from Conflux eSpace contracts through JSON-RPC calls, not from a separate backend API.

## Page Composition

Consumer subscription detail route:

```text
dapps/payment/src/modules/Consumer/APP/index.tsx
```

It renders:

- `Common/APP/Detail` for general app information
- `Consumer/APP/SubscriptionInfo` for subscription templates

## General App Details

Rendered labels:

- APP Name
- Symbol
- Link
- APP Address
- Description

Frontend path:

```text
dapps/payment/src/modules/Common/APP/Detail.tsx
```

Data function:

```text
getAPP(address)
```

`getAPP` calls:

```text
getAPPsDetail([address])
```

`getAPPsDetail` first resolves related contracts with app calls:

```text
getAppCoin()
getVipCoin()
getApiWeightToken()
cardShop()
```

Then it reads app fields:

```text
link()
paymentType()
totalCharged()
totalTakenProfit()
description()
deferTimeSecs()
```

It also reads display fields from the related VIP coin:

```text
name()
symbol()
```

Equivalent `cast` checks:

```bash
cast call <app> 'link()(string)' --rpc-url https://evm.confluxrpc.com
cast call <app> 'description()(string)' --rpc-url https://evm.confluxrpc.com
cast call <app> 'paymentType()(uint8)' --rpc-url https://evm.confluxrpc.com
cast call <app> 'getVipCoin()(address)' --rpc-url https://evm.confluxrpc.com
cast call <vipCoin> 'name()(string)' --rpc-url https://evm.confluxrpc.com
cast call <vipCoin> 'symbol()(string)' --rpc-url https://evm.confluxrpc.com
```

## Subscription Resource Details

Rendered labels:

- Resource Name
- Price
- Basic Days
- Giveaways
- Configuration

Frontend path:

```text
dapps/payment/src/modules/Consumer/APP/SubscriptionInfo.tsx
```

Data function:

```text
getAPPCards(address)
```

`getAPPCards` resolves:

```text
app.cardShop()
cardShop.template()
cardTemplate.list(0, 1e8)
```

It maps template fields:

- `id`
- `name`
- `price`, formatted from 18 decimals
- `duration`, converted from seconds to days
- `giveawayDuration`, converted from seconds to days
- `description`
- `props.keys` and `props.values` as configuration rows

Equivalent `cast` checks:

```bash
cast call <app> 'cardShop()(address)' --rpc-url https://evm.confluxrpc.com
cast call <cardShop> 'template()(address)' --rpc-url https://evm.confluxrpc.com
cast call <template> 'list(uint256,uint256)((uint256,string,string,uint256,uint256,uint256,(string[],string[]))[],uint256)' 0 20 --rpc-url https://evm.confluxrpc.com
```

## Paid App Validity

The user's paid-app view uses a read-functions utility contract, still through chain calls:

```text
getPaidAPPs(account)
```

It calls:

```text
util.listAppByUser(account, 0, 1e8)
```

For subscription apps, the frontend maps:

- `vipCardName` to subscription name
- `vipExpireAt` to expiration timestamp
- `cardShop` to the subscription shop contract

For operational validity checks, prefer the direct tracker read used by this skill:

```bash
cast call <tracker> 'getVipInfo(address)((uint256,(string[],string[]),string))' <user> --rpc-url https://evm.confluxrpc.com
```

This returns:

- `expireAt`
- template props
- subscription name

## API Key Claim

The API key modal does not fetch a backend key. It asks the wallet to sign:

```json
{"domain":"web3pay","contract":"<app address>"}
```

Then the frontend base58-encodes the signature bytes. The helper script's `claim` command mirrors that behavior.

## Verified Example: ConfluxScan API

App:

```text
0x7f55828e334e63065b88055776db3a58734220ad
```

Observed chain reads:

```text
link(): https://api.confluxscan.io/doc
description(): ConfluxScan is the leading blockchain explorer, search, analytics platform and developer API for Conflux Block Chain...
getVipCoin(): 0x32c883FD2393ab0C1Fc452aab3515DdDEE76a235
vipCoin.name(): ConfluxScan API Pro-Service
```
