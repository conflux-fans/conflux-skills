# Pytest scope considerations (integration tests)

## When choosing scope, consider
- **Isolation vs speed**: `session` is fastest but shares state across modules; `function` is most isolated but slowest; `module` is a good balance.
- **Node lifecycle cost**: starting Conflux nodes is expensive; avoid `function` scope for `network`.
- **Parallel execution**: with xdist + `--dist loadscope`, module scope keeps related tests on one worker while still isolating modules across workers.
- **Statefulness**: tests that depend on clean chain state should avoid `session` scope unless they fully reset state.
- **Port allocation**: module scope + default `port_min` fixture prevents conflicts across workers.

## Key source code (paths and excerpts)

### Module-scoped fixtures
`integration_tests/tests/conftest.py`
```python
@pytest.fixture(scope="module")
def framework_class() -> Type[ConfluxTestFramework]:
    return DefaultFramework

@pytest.fixture(scope="module")
def network(framework_class: Type[ConfluxTestFramework], port_min: int, additional_secrets: int, args: FrameworkOptions, request: pytest.FixtureRequest):
    try:
        framework = framework_class(port_min, additional_secrets, options=args)
    except Exception as e:
        pytest.fail(f"Failed to setup framework: {e}")
    yield framework
    framework.teardown(request)
```

### Port allocation per worker
`integration_tests/tests/conftest.py`
```python
PORT_MIN = 11000
PORT_RANGE = 100

@pytest.fixture(scope="module")
def port_min(worker_id: str) -> int:
    index = int(worker_id.split("gw")[1]) if "gw" in worker_id else 0
    return PORT_MIN + index * PORT_RANGE
```

### Framework uses fixture-provided port range
`integration_tests/test_framework/test_framework.py`
```python
self.port_min = self.options.port_min or port_min
```
