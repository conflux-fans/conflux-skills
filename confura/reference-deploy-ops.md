# Confura Build, Run, Deploy, and Validate

This is secondary to the user-facing RPC guide. Use it when the user is running or modifying Confura.

## Build

Confura requires Go 1.22+.

```bash
go version
go build -o bin/confura
make build
```

## Run components

```bash
./confura sync --db
./confura sync --eth
./confura nm --cfx
./confura nm --eth
./confura vf --cfx
./confura vf --eth
./confura rpc --cfx
./confura rpc --cfxBridge
./confura rpc --eth
```

## Validate proxy vs fullnode

```bash
./confura test cfx --fn-endpoint http://FULLNODE --infura-endpoint http://RPC_PROXY
./confura test eth --fn-endpoint http://FULLNODE --infura-endpoint http://RPC_PROXY
./confura test ws  --fn-endpoint ws://FULLNODE --infura-endpoint ws://RPC_PROXY
./confura test vf  --fn-endpoint http://FULLNODE --infura-endpoint http://VIRTUAL_FILTER
```

## Docker quick start

```bash
docker-compose build
docker-compose up -d
docker-compose ps
```

## Configuration notes

Confura loads config from:

```text
config.yml
config/config.yml
```

Environment variables prefixed with `INFURA_` override matching config paths.

## Exposed modules

Core RPC modules include:

```text
cfx, txpool, pos, trace, debug, gasstation, diagnostic
```

EVM RPC modules include:

```text
eth, web3, net, trace, parity, debug, txpool, gasstation, diagnostic
```

The `diagnostic` module must be exposed before `diagnostic_getRateLimitStatus` can be called.

## getLogs-related config concepts

Request control contains:

```text
requestControl.maxGetLogsSuggestionAttempts
requestControl.logFilter.maxBlockHashCount
requestControl.logFilter.maxAddressCount
requestControl.logFilter.maxTopicCount
requestControl.logFilter.maxSplitEpochRange
requestControl.logFilter.maxSplitBlockRange
requestControl.resourceLimits.MaxGetLogsResponseBytes
```
