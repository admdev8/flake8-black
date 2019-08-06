#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Assumes in the tests/ directory

echo "Checking our configuration option appears in help"
flake8 -h 2>&1 | grep "black-config"

set +o pipefail

echo "Checking we report an error when can't find specified config file"
flake8 --black-config does_not_exist.toml 2>&1 | grep -i "could not find"

echo "Checking failure with mal-formed TOML file"
flake8 --select BLK test_cases/ --black-config with_bad_toml/pyproject.toml 2>&1 | grep -i "could not parse"

set -o pipefail

echo "Checking we report no errors on these test cases"
flake8 --select BLK test_cases/*.py
# Adding --black-config '' should have no effect:
flake8 --select BLK test_cases/*.py --black-config ''
# Adding --black-config '-' would ignore any pyproject.toml file:
flake8 --select BLK test_cases/*.py --black-config '-'
flake8 --select BLK --max-line-length 50 test_cases/*.py
flake8 --select BLK --max-line-length 90 test_cases/*.py
flake8 --select BLK with_pyproject_toml/*.py
flake8 --select BLK with_pyproject_toml/*.py --black-config with_pyproject_toml/pyproject.toml
flake8 --select BLK without_pyproject_toml/*.py --config=flake8_config/flake8
flake8 --select BLK --max-line-length 88 with_pyproject_toml/
flake8 --select BLK without_pyproject_toml/*.py --black-config with_pyproject_toml/pyproject.toml
# Adding --black-config '' should have no effect:
flake8 --select BLK --max-line-length 88 with_pyproject_toml/ --black-config ''
flake8 --select BLK non_conflicting_configurations/*.py
flake8 --select BLK conflicting_configurations/*.py
# Here testing using --black-config '-' to ignore the broken pyproject.toml file:
flake8 --select BLK with_bad_toml/hello_world.py --black-config '-'

echo "Checking we report expected black changes"
diff test_changes/hello_world.txt <(flake8 --select BLK test_changes/hello_world.py)
diff test_changes/hello_world_EOF.txt <(flake8 --select BLK test_changes/hello_world_EOF.py)
diff test_changes/hello_world_EOF.txt <(flake8 --select BLK test_changes/hello_world_EOF.py --black-config '')
diff with_bad_toml/hello_world.txt <(flake8 --select BLK with_bad_toml/hello_world.py)

echo "Tests passed."
