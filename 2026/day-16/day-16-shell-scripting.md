# Bash Scripting Tasks

## Task 1: Your First Script

### Objective
- Create a file `hello.sh`
- Add the shebang line `#!/bin/bash`
- Print **Hello, DevOps!** using `echo`
- Make the script executable and run it
- Document what happens if the shebang line is removed

### Script (`hello.sh`)

```bash
#!/bin/bash

echo "Hello, DevOps!"
```

### Execution

```bash
root@ubuntu-host ~/scripts ➜ cat hello.sh
#!/bin/bash

echo "Hello, DevOps!"

root@ubuntu-host ~/scripts ➜ ./hello.sh
Hello, DevOps!
```

### Removing the Shebang

```bash
root@ubuntu-host ~/scripts ➜ cat hello.sh

echo "Hello, DevOps!"

root@ubuntu-host ~/scripts ➜ ./hello.sh
Hello, DevOps!
```

### Observation

If the shebang (`#!/bin/bash`) is removed:

- The script may still execute successfully when run from an interactive Bash shell because Bash automatically interprets it.
- However, the behavior is **not guaranteed** across different shells or environments.
- The shebang explicitly tells the operating system which interpreter should execute the script, making it portable and reliable.

---

# Task 2: Variables

## Objective

Create `variables.sh` that:

- Stores your **NAME**
- Stores your **ROLE**
- Prints:

```
Hello, I am <NAME> and I am a <ROLE>
```

- Compare **single quotes** and **double quotes**.

### Script (`variables.sh`)

```bash
#!/bin/bash

NAME="Lohit"
ROLE="Sr. Devops Engineer"

echo "Hello I'm ${NAME} and I'm a ${ROLE}"
```

### Execution

```bash
root@ubuntu-host ~/scripts ➜ cat variables.sh
#!/bin/bash

NAME="Lohit"
ROLE="Sr. Devops Engineer"

echo "Hello I'm ${NAME} and I'm a ${ROLE}"

root@ubuntu-host ~/scripts ➜ ./variables.sh
Hello I'm Lohit and I'm a Sr. Devops Engineer
```

### Difference Between Single and Double Quotes

| Double Quotes (`" "`) | Single Quotes (`' '`) |
|------------------------|-----------------------|
| Variables are expanded. | Variables are treated as literal text. |
| Supports command substitution. | No variable expansion or command substitution. |
| Recommended for most string assignments. | Use when you want the exact text stored. |

Example:

```bash
NAME="Lohit"

echo "$NAME"
# Output: Lohit

echo '$NAME'
# Output: $NAME
```

---

# Task 3: User Input with `read`

## Objective

Create `greet.sh` that:

- Asks the user for their name
- Asks for their favourite tool
- Prints:

```
Hello <name>, your favourite tool is <tool>
```

### Script (`greet.sh`)

```bash
#!/bin/bash

read -p "Enter your name: " name
read -p "Enter your favourite tool: " tool

echo "Hello ${name}, your favourite tool is ${tool}"
```

### Execution

```bash
root@ubuntu-host ~/scripts ➜ cat greet.sh
#!/bin/bash

read -p "Enter your name: " name
read -p "Enter your favourite tool: " tool

echo "Hello ${name}, your favourite tool is ${tool}"

root@ubuntu-host ~/scripts ➜ ./greet.sh
Enter your name: Lohit
Enter your favourite tool: VsCode
Hello Lohit, your favourite tool is VsCode
```

---

# Task 4: If-Else Conditions

## 4.1 Number Checker

### Objective

Create `check_number.sh` that:

- Reads a number from the user
- Prints whether it is:
  - Positive
  - Negative
  - Zero

### Script (`check_number.sh`)

```bash
#!/bin/bash

echo "
Number checker that will check if the given number is Positive, Negative or Zero
"

read -p "Enter your number: " number

if [ "$number" -gt 0 ]; then
    echo "${number} is a positive number"
elif [ "$number" -lt 0 ]; then
    echo "${number} is a negative number"
else
    echo "${number} is zero"
fi
```

### Execution

#### Positive Number

```bash
root@ubuntu-host ~/scripts ➜ ./check_number.sh

Number checker that will check if the given number is Positive, Negative or Zero

Enter your number: 2
2 is a positive number
```

#### Negative Number

```bash
root@ubuntu-host ~/scripts ➜ ./check_number.sh

Number checker that will check if the given number is Positive, Negative or Zero

Enter your number: -2
-2 is a negative number
```

#### Zero

```bash
root@ubuntu-host ~/scripts ➜ ./check_number.sh

Number checker that will check if the given number is Positive, Negative or Zero

Enter your number: 0
0 is zero
```

---

## 4.2 File Checker

### Objective

Create `file_check.sh` that:

- Reads a filename
- Checks whether it exists using `-f`
- Prints an appropriate message

### Script (`file_check.sh`)

```bash
#!/bin/bash

echo "
Check whether a given file exists.
"

read -p "Enter file name: " filename

if [ -f "$filename" ]; then
    echo "${filename} exists."
else
    echo "${filename} does not exist."
fi
```

### Execution

```bash
root@ubuntu-host ~/scripts ➜ ./file_check.sh
Enter file name: hello.sh
hello.sh exists.

root@ubuntu-host ~/scripts ➜ ./file_check.sh
Enter file name: demo.txt
demo.txt does not exist.
```

---

# Task 5: Combine It All

## Objective

Create `server_check.sh` that:

- Stores service names in variables (or an array)
- Asks:

```
Do you want to check the status? (y/n)
```

- If `y`, checks whether the services are active.
- If `n`, prints `Skipped.`

### Script (`server_check.sh`)

```bash
#!/bin/bash

services=("nginx" "ssh" "docker")

read -rp "Do you want to check the status? (y/n): " choice

if [ "$choice" = "y" ]; then
    for service in "${services[@]}"
    do
        if systemctl is-active --quiet "$service"; then
            echo "$service: Active"
        else
            echo "$service: Not Active"
        fi
    done
else
    echo "Skipped."
fi
```

### Execution

#### Option 1

```bash
root@ubuntu-host ~/scripts ➜ ./server_check.sh

Do you want to check the status? (y/n): y

nginx: Not Active
ssh: Active
docker: Not Active
```

#### Option 2

```bash
root@ubuntu-host ~/scripts ➜ ./server_check.sh

Do you want to check the status? (y/n): n

Skipped.
```

---

