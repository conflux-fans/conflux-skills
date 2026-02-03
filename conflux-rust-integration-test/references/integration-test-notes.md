# Integration test notes (Conflux Rust)

## Common interfaces and setup
- `network.client`: `RpcClient` bound to node 0; exposes raw/typed RPC helpers (e.g., `epoch_number()`).
- `network.cw3` / `network.ew3`: Conflux/eSpace Web3 instances; ready after `before_test()` calls `setup_w3()`.
- `network.cfx` / `network.eth`: convenience accessors for `cw3.cfx` and `ew3.eth`.
- `core_accounts` / `evm_accounts`: pre-funded genesis accounts derived from secrets.
- `internal_contracts`: mapping of common internal contracts (e.g., `SponsorWhitelistControl`).
- Override `setup_network()` to change topology; override `set_test_params()` to change node count or config.

## Block production and execution (integration_tests)
- A tx is considered executed after 5 blocks are produced; `wait_for_receipt()` first calls `generate_blocks_to_state()` (defaults to 5 blocks).
- `network.cfx` / `network.eth` methods auto-trigger those 5 blocks via TestNodeMiddleware when receipt is missing (`cfx_getTransactionReceipt` / `eth_getTransactionReceipt`).
- Manual mining: call `network.rpc.generate_blocks_to_state(num_txs=1)` (or `generate_blocks(5, num_txs=1)` / `generate_block(num_txs=1)`).

## Custom block usage (without fee details)
- `rpc.generate_custom_block(parent_hash=..., txs=[...], referee=[...])` lets you build a block with an explicit parent and exact tx list; pass `referee=[]` for a simple chain extension.
- `txs` is a list of raw tx dicts returned by `rpc.new_tx(...)` or `rpc.new_typed_tx(...)`; prepare and sign them first, then pass the list directly.
- The call returns the new block hash; use it as `parent_hash` for subsequent custom blocks to form a deterministic chain.
- Use empty blocks (`txs=[]`) to advance epochs or trigger execution without adding new transactions.
- Fetch the block with `rpc.block_by_hash(block_hash, True)` when you need full transaction objects (statuses, blockHash, etc.).
- Example tests that use custom blocks: `integration_tests/tests/cip137_test.py`.

## set_test_params() and conf_parameters
- In `set_test_params()`, always set `self.num_nodes`; optionally tweak `self.conf_parameters` (node config) and `self.pos_parameters`.
- Common params in tests include: `cip1559_transition_height`, `public_rpc_apis`, `min_native_base_price`, `base_fee_burn_transition_height/number`, `executive_trace`, `next_hardfork_transition_height/number`, and PoS params like `pos_round_per_term`.
- `conf_parameters` is a dict of config key/value pairs written into each node's `conflux.conf` by `initialize_datadir()`.
- Values are written verbatim; use `str(...)` for numbers and quote strings when needed (e.g., `""cfx,debug""`).
- Config merge order is: generated per-node ports → `integration_tests.conflux.config.small_local_test_conf` → `conf_parameters`.

Rust config keys and defaults live in:
- `crates/config/src/configuration.rs` (authoritative list of config fields)

Python integration points:
- `integration_tests/test_framework/util/__init__.py` (`initialize_datadir` writes `conflux.conf`)
- `integration_tests/conflux/config.py` (`small_local_test_conf` defaults)

## Pytest common issues and fixes
- Verify interpreter and pytest come from the same venv: run `which python` and `which pytest`.
- If `pytest` or `python` are not under `.venv/`, activation likely failed; re-activate the venv or rerun `source ./dev-support/activate_new_venv.sh`.
- If path mismatches persist, try `uv pytest <args>` to force a clean, consistent environment.

## Key files to consult
- `integration_tests/readme.md` for setup and pytest options.
- `integration_tests/tests/conftest.py` for default fixtures and options.
- `integration_tests/test_framework/framework_templates.py` for default frameworks.
- Example tests: `integration_tests/tests/message_test.py`, `integration_tests/tests/cip137_test.py`, `integration_tests/tests/rpc/espace/conftest.py`.

## Template
- Copy `assets/basic_test_template.py` into the target folder and tailor it.
- For custom block usage, copy `assets/custom_block_example.py` and adapt the helper into your test module.
