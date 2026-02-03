import pytest
from typing import Type

from integration_tests.test_framework.test_framework import ConfluxTestFramework
from integration_tests.test_framework.framework_templates import DefaultFramework


# Optional: override the default framework when you need custom config.
# Delete this fixture if the defaults are sufficient.
@pytest.fixture(scope="module")
def framework_class() -> Type[ConfluxTestFramework]:
    return DefaultFramework


def test_example(network: ConfluxTestFramework, cw3, core_accounts):
    # Example: simple sanity check to ensure the node is running.
    assert network.nodes, "expected at least one node"

    # TODO: replace with actual test logic.
    latest_epoch = network.client.epoch_number()
    assert isinstance(latest_epoch, int)
