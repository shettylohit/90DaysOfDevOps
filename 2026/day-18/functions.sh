# Task 1: Basic Functions

Create a Bash script named `functions.sh` that:

- Defines a function `greet` that takes a name as an argument and prints `Hello, <name>!`
- Defines a function `add` that takes two numbers and prints their sum
- Calls both functions from the script

## Solution

#!/usr/bin/env bash

greet() {
    echo "Hello, $1"
}

addition() {
    sum=$(($1 + $2))
    echo $sum
}

greet "Alice"
addition 6 4


## Output

root@ubuntu-host ~/scripts ➜ ./functions.sh
Hello, Alice
10


