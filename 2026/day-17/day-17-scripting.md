````markdown
# Bash Scripting Practice Tasks

This repository contains solutions for common Bash scripting exercises covering loops, user input, command-line arguments, package installation, and error handling.

---

# Task 1: For Loop

## Objective

### Create `for_loop.sh` that:

- Loops through a list of **5 fruits**
- Prints each fruit

### Create `count.sh` that:

- Prints numbers **1 to 10** using a `for` loop

---

## Solution: `for_loop.sh`

```bash
#!/bin/bash

fruits=("Apple" "Banana" "Watermelon" "Papaya")

for i in "${fruits[@]}"; do
    echo "$i"
done
```

### Output

```text
Apple
Banana
Watermelon
Papaya
```

> **Note:** The task requested 5 fruits, but this script currently contains 4. Add another fruit (for example, `"Orange"`) to fully meet the requirement.

---

## Solution: `count.sh`

```bash
#!/bin/bash

for i in {1..10}; do
    echo "$i"
done
```

### Output

```text
1
2
3
4
5
6
7
8
9
10
```

---

# Task 2: While Loop

## Objective

Create `countdown.sh` that:

- Takes a number from the user
- Counts down to **0**
- Prints **"Done!"** at the end

---

## Solution

```bash
#!/bin/bash

read -p "Please enter a number: " number

while [[ "$number" -gt 0 ]]; do
    echo "$number"
    number=$((number - 1))
done

echo "0"
echo "Done!"
```

### Output

```text
Please enter a number: 5
5
4
3
2
1
0
Done!
```

---

# Task 3: Command-Line Arguments

## Objective

### Create `greet.sh`

- Accepts a name as `$1`
- Prints:

```text
Hello, <name>!
```

- If no argument is provided:

```text
Usage: ./greet.sh <name>
```

---

## Solution: `greet.sh`

```bash
#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Usage: ./greet.sh <name>"
else
    echo "Hello, $1!"
fi
```

### Example

```bash
./greet.sh John
```

Output

```text
Hello, John!
```

---

## Create `args_demo.sh`

Print:

- Script name (`$0`)
- Number of arguments (`$#`)
- All arguments (`$@`)

---

## Solution

```bash
#!/bin/bash

echo "Script Name (\$0):      $0"
echo "Total Arguments (\$#):  $#"
echo "All Arguments (\$@):    $@"
```

### Example

```bash
./args_demo.sh hello mark
```

Output

```text
Script Name ($0):      ./args_demo.sh
Total Arguments ($#):  2
All Arguments ($@):    hello mark
```

---

# Task 4: Install Packages via Script

## Objective

Create `install_packages.sh` that:

- Defines a list of packages
- Checks whether each package is installed
- Installs missing packages
- Skips already installed packages
- Prints the status for each package

Run as **root** or with **sudo**.

---

## My Solution

```bash
#!/usr/bin/env bash

packages=("nginx" "curl" "wget")

if command -v dpkg >/dev/null 2>&1; then

    for package in "${packages[@]}"; do

        if dpkg -s "$package" >/dev/null 2>&1; then
            echo "$package is already installed."
        else
            sudo apt-get install -y "$package"
        fi

    done

elif command -v rpm >/dev/null 2>&1; then

    for package in "${packages[@]}"; do

        if rpm -q "$package" >/dev/null 2>&1; then
            echo "$package is already installed."
        else
            sudo dnf install -y "$package" || sudo yum install -y "$package"
        fi

    done

else
    echo "Unsupported package manager."
    exit 1
fi
```

---

## Improved Version

```bash
#!/usr/bin/env bash

set -euo pipefail

packages=("nginx" "curl" "wget" "docker" "tree")

if ! command -v dpkg >/dev/null 2>&1; then
    echo "Error: This script supports Debian/Ubuntu systems only."
    exit 1
fi

for package in "${packages[@]}"; do

    if dpkg -s "$package" >/dev/null 2>&1; then
        echo "✅ $package is already installed."
    else
        echo "📦 Installing $package..."

        if sudo apt-get install -y "$package"; then
            echo "✅ $package installed successfully."
        else
            echo "❌ Failed to install $package."
        fi
    fi

done
```

---

## Refactored Version Using Functions

```bash
#!/usr/bin/env bash

set -euo pipefail

packages=("nginx" "curl" "wget" "docker" "tree")

is_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

install_package() {
    sudo apt-get install -y "$1"
}

for package in "${packages[@]}"; do

    if is_installed "$package"; then
        echo "✅ $package already installed."
    else
        echo "📦 Installing $package..."
        install_package "$package"
    fi

done
```

---

# Task 5: Error Handling

## Objective

Create `safe_script.sh` that:

- Uses `set -e`
- Creates `/tmp/devops-test`
- Navigates into it
- Creates a file
- Uses `||` for error handling

---

## Solution

```bash
#!/usr/bin/env bash

set -euo pipefail

mkdir /tmp/devops-test || echo "Directory already exists"

cd /tmp/devops-test

touch test1.txt || echo "File already exists"
```

---

## Modify `install_packages.sh`

Check whether the script is run as **root**.

If not, exit with an error.

---

## Solution

```bash
#!/bin/bash

packages=("nginx" "curl" "wget" "docker" "tree")

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run this script as root or using sudo."
    exit 1
fi

for item in "${packages[@]}"; do

    if dpkg -s "$item" >/dev/null 2>&1; then
        echo "$item installed"
    else
        apt install -y "$item"
    fi

done
```

---
````
