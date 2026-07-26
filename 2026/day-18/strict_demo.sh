Task 3: Strict Mode — set -euo pipefail
Create strict_demo.sh with set -euo pipefail at the top
Try using an undefined variable — what happens with set -u?
Try a command that fails — what happens with set -e?
Try a piped command where one part fails — what happens with set -o pipefail?
Document: What does each flag do?

set -e →  This flag will stop the script if the commands fails
set -u →  This flag will stop the script if there is undefined variable
set -o pipefail → This will stop the script if the commands that is piped fails




#!/bin/bash

# Strict mode
set -euo pipefail

echo "=== Strict Mode Demo ==="

# -------------------------
# Demo 1: set -u
# -------------------------
echo "Testing undefined variable..."
echo "$UNDEFINED_VAR"

# -------------------------
# Demo 2: set -e
# -------------------------
echo "Testing failing command..."
false

# -------------------------
# Demo 3: set -o pipefail
# -------------------------
echo "Testing pipeline failure..."
cat missing_file.txt | grep "hello"

echo "This line will not be reached if any error occurs."
