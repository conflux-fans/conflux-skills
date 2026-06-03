# Conflux docs – extended reference

Additional doc links for less common or task-specific topics.

## General resources

* Contributing to docs: https://doc.confluxnetwork.org/docs/general/CONTRIBUTING/
* Grants: https://doc.confluxnetwork.org/docs/general/build/grants
* Research papers: https://doc.confluxnetwork.org/docs/general/conflux-basics/additional-resources/papers.md
* Protocol specification / yellow paper: https://confluxnetwork.org/files/Conflux_Protocol_Specification.pdf

## eSpace

### Address format

* Ethereum-style `0x` (42-char hex). Same as Ethereum.

### Tutorials

* Verify contracts: https://doc.confluxnetwork.org/docs/espace/tutorials/VerifyContracts
* Deploy with Hardhat / Foundry: https://doc.confluxnetwork.org/docs/espace/tutorials/deployContract/hardhatAndFoundry
* Deploy with Remix: https://doc.confluxnetwork.org/docs/espace/tutorials/deployContract/remix
* Deploy with Brownie: https://doc.confluxnetwork.org/docs/espace/tutorials/deployContract/brownie
* Scaffold Conflux: https://doc.confluxnetwork.org/docs/espace/tutorials/scaffoldCfx/scaffold
* Transfer funds across spaces: https://doc.confluxnetwork.org/docs/general/tutorials/transferring-funds/transfer-funds-across-spaces

### RPC and infrastructure

* Official public RPC / Confura endpoints, API keys, rate limits, and enhanced features: https://doc.confluxnetwork.org/docs/espace/network-endpoints
* Third-party eSpace RPC providers: https://doc.confluxnetwork.org/docs/espace/build/infrastructure/RPC-Provider

### JSON-RPC

* Ethereum JSON-RPC method reference for standard `eth_*`, `net_*`, and `web3_*` methods: https://ethereum.org/developers/docs/apis/json-rpc/#json-rpc-methods
* eSpace JSON-RPC compatibility, supported methods, unsupported methods, Conflux-specific RPCs, and behavior differences: https://doc.confluxnetwork.org/docs/espace/build/jsonrpc-compatibility

Use the Ethereum JSON-RPC reference for standard method parameters and return values. Use the eSpace compatibility page to check whether a method is supported on Conflux eSpace and whether its behavior differs from Ethereum.

## Core Space

### Address format

* CIP-37, e.g. `cfx:aatktb2te25ub7dmyag3p8bbdgr31vrbeackztm2rj` (network prefix + base32).

### RPC and infrastructure

* Official public RPC / Confura endpoints, API keys, rate limits, enhanced features, and currently documented third-party providers: https://doc.confluxnetwork.org/docs/core/conflux_rpcs

### JSON-RPC

* Core Space JSON-RPC specification, including namespaces, method parameters, return values, and common RPC behavior: https://doc.confluxnetwork.org/docs/core/build/json-rpc/
