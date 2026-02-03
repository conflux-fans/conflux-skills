# Core fixtures and options

This is a concise summary of the default fixtures in `integration_tests/tests/conftest.py`.
Always confirm against the source if behavior seems different.

## Core fixtures
- `args`: `FrameworkOptions` built from pytest CLI options.
- `framework_class`: default `DefaultFramework` from `integration_tests/test_framework/framework_templates.py`.
- `network`: instance of `ConfluxTestFramework`; auto-teardown after module.
- `port_min`: worker-specific port base (accounts for xdist `gw*` workers).
- `additional_secrets`: number of extra genesis secrets to pre-create (default 0).
- `cw3`: Conflux Web3 instance from the framework.
- `ew3`: eSpace Web3 instance from the framework.
- `ew3_tracing`: `Tracing` helper from `ew3.tracing`.
- `core_accounts`: pre-funded Core space accounts.
- `evm_accounts`: pre-funded eSpace accounts.
- `internal_contracts`: mapping of common internal contracts.

## Overriding the framework
- Define `framework_class` in the test module or a local `conftest.py`.
- Subclass `ConfluxTestFramework` and override `set_test_params()` and `setup_network()`.
- Example pattern: `integration_tests/tests/rpc/espace/conftest.py`.

## Useful pytest options
- `-vv`: verbose output.
- `-s`: show `print` output (avoid with `-n`).
- `-k <expr>`: filter tests.
- `-n logical` and `--dist loadscope`: parallel runs (xdist).
- `--conflux-tracetx`: print opcode traces on receipt fetch.
- `--conflux-use-anvil`: use anvil for spec tests (where supported).
- `--conflux-nocleanup` / `--conflux-noshutdown`: keep logs/nodes.
- `--conflux-loglevel <LEVEL>`: control framework logging.
