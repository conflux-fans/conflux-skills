"""
Minimal custom block example for Conflux integration tests.
Copy into integration_tests/tests and adapt.
"""

from integration_tests.conflux.rpc import RpcClient
from integration_tests.test_framework.test_framework import ConfluxTestFramework


def build_custom_block_with_txs(
    rpc: RpcClient, parent_hash: str, sender_priv_key: str
) -> str:
    # Build raw tx dicts first, then pass as a list to generate_custom_block.
    txs = [
        rpc.new_tx(
            receiver=rpc.rand_addr(),
            priv_key=sender_priv_key,
            nonce=0,
            value=1,
        ),
        rpc.new_typed_tx(
            receiver=rpc.rand_addr(),
            priv_key=sender_priv_key,
            nonce=1,
            max_fee_per_gas=rpc.base_fee_per_gas() * 2,
        ),
    ]
    return rpc.generate_custom_block(parent_hash=parent_hash, txs=txs, referee=[])


def example_usage(network: ConfluxTestFramework, sender_priv_key: str) -> None:
    parent = network.rpc.block_by_epoch("latest_mined")["hash"]
    custom_block = build_custom_block_with_txs(network.rpc, parent, sender_priv_key)
    full_block = network.rpc.block_by_hash(custom_block, True)
    network.log.info("custom block tx count: %s", len(full_block["transactions"]))
