Here's a complete Markdown cheat sheet you can save as **`shell_scripting_cheatsheet.md`**.

````markdown
# Shell Scripting Cheat Sheet

A quick reference guide for Bash Shell Scripting covering syntax, commands, loops, functions, text processing, debugging, and useful one-liners.

---

# Task 1: Basics

## 1. Shebang

```bash
#!/bin/bash
```

### What it does
Tells the operating system which interpreter should execute the script.

### Why it matters
- Ensures the correct shell is used.
- Makes scripts portable and predictable.

---

## 2. Running a Script

### Give execute permission

```bash
chmod +x script.sh
```

### Execute directly

```bash
./script.sh
```

### Run with bash

```bash
bash script.sh
```

Difference:

- `./script.sh` requires execute permission.
- `bash script.sh` does not.

---

## 3. Comments

### Single-line

```bash
# This is a comment
```

### Inline

```bash
echo "Hello" # Prints Hello
```

---

## 4. Variables

### Declare

```bash
NAME="John"
AGE=25
```

### Use

```bash
echo $NAME
echo "$NAME"
```

### Quoting

```bash
"$NAME"
```

Expands the variable.

```bash
'$NAME'
```

Prints literally:

```
$NAME
```

Always quote variables unless you intentionally want word splitting.

---

## 5. Reading User Input

```bash
read NAME

echo "Hello $NAME"
```

Prompt example:

```bash
read -p "Enter username: " USER
```

---

## 6. Command Line Arguments

Example:

```bash
bash script.sh file.txt backup
```

Inside script:

```bash
echo $0
echo $1
echo $2
echo $#
echo $@
echo $?
```

Meaning:

| Variable | Meaning |
|----------|---------|
| `$0` | Script name |
| `$1` | First argument |
| `$2` | Second argument |
| `$#` | Number of arguments |
| `$@` | All arguments |
| `$?` | Exit status of previous command |

---

# Task 2: Operators and Conditionals

## String Comparisons

```bash
[ "$A" = "$B" ]

[ "$A" != "$B" ]

[ -z "$A" ]

[ -n "$A" ]
```

Example

```bash
if [ "$USER" = "root" ]
then
    echo "Administrator"
fi
```

---

## Integer Comparisons

```bash
-eq
-ne
-lt
-gt
-le
-ge
```

Example

```bash
if [ "$AGE" -ge 18 ]
then
    echo "Adult"
fi
```

---

## File Test Operators

| Operator | Meaning |
|-----------|---------|
| `-f` | Regular file |
| `-d` | Directory |
| `-e` | Exists |
| `-r` | Readable |
| `-w` | Writable |
| `-x` | Executable |
| `-s` | Not empty |

Example

```bash
if [ -f file.txt ]
then
    echo "Exists"
fi
```

---

## if / elif / else

```bash
if [ condition ]
then
    commands

elif [ condition ]
then
    commands

else
    commands
fi
```

---

## Logical Operators

AND

```bash
[ "$A" = "yes" ] && echo "True"
```

OR

```bash
command || echo "Failed"
```

NOT

```bash
if ! grep "root" file.txt
then
    echo "Not found"
fi
```

---

## Case Statement

```bash
case "$1" in

start)
    echo "Starting"
    ;;

stop)
    echo "Stopping"
    ;;

restart)
    echo "Restarting"
    ;;

*)
    echo "Invalid option"
    ;;

esac
```

---

# Task 3: Loops

## For Loop

### List Based

```bash
for name in Alice Bob Charlie
do
    echo "$name"
done
```

### C Style

```bash
for ((i=1;i<=5;i++))
do
    echo "$i"
done
```

---

## While Loop

```bash
count=1

while [ $count -le 5 ]
do
    echo $count
    ((count++))
done
```

---

## Until Loop

```bash
count=1

until [ $count -gt 5 ]
do
    echo $count
    ((count++))
done
```

---

## break

```bash
for i in {1..10}
do
    if [ "$i" -eq 5 ]
    then
        break
    fi

    echo "$i"
done
```

---

## continue

```bash
for i in {1..5}
do
    if [ "$i" -eq 3 ]
    then
        continue
    fi

    echo "$i"
done
```

---

## Loop Through Files

```bash
for file in *.log
do
    echo "$file"
done
```

---

## Loop Through Command Output

```bash
cat users.txt | while read line
do
    echo "$line"
done
```

Better practice:

```bash
while read line
do
    echo "$line"
done < users.txt
```

---

# Task 4: Functions

## Define Function

```bash
hello() {
    echo "Hello"
}
```

---

## Call Function

```bash
hello
```

---

## Function Arguments

```bash
greet() {
    echo "Hello $1"
}

greet Alice
```

---

## Return Values

Using return

```bash
myfunc() {
    return 0
}
```

Using echo

```bash
square() {
    echo $(($1 * $1))
}

result=$(square 5)
```

Use `return` for exit status (0–255), and `echo` to output data.

---

## Local Variables

```bash
show() {

    local name="John"

    echo "$name"

}
```

---

# Task 5: Text Processing Commands

## grep

Search text

```bash
grep "error" file.log
```

Ignore case

```bash
grep -i error file.log
```

Recursive

```bash
grep -r error .
```

Count matches

```bash
grep -c error file.log
```

Line numbers

```bash
grep -n error file.log
```

Invert match

```bash
grep -v error file.log
```

Extended regex

```bash
grep -E "error|warning"
```

---

## awk

Print column

```bash
awk '{print $1}'
```

Custom delimiter

```bash
awk -F, '{print $2}'
```

Pattern

```bash
awk '/error/'
```

BEGIN

```bash
awk 'BEGIN {print "Start"}'
```

END

```bash
awk 'END {print "Done"}'
```

---

## sed

Replace

```bash
sed 's/foo/bar/'
```

Global replace

```bash
sed 's/foo/bar/g'
```

Delete line

```bash
sed '5d'
```

In-place edit

```bash
sed -i 's/foo/bar/g' file.txt
```

---

## cut

By delimiter

```bash
cut -d',' -f2 file.csv
```

Characters

```bash
cut -c1-5
```

---

## sort

Alphabetical

```bash
sort names.txt
```

Numeric

```bash
sort -n numbers.txt
```

Reverse

```bash
sort -r names.txt
```

Unique

```bash
sort -u names.txt
```

---

## uniq

Remove duplicates

```bash
uniq file.txt
```

Count

```bash
uniq -c file.txt
```

---

## tr

Uppercase

```bash
tr 'a-z' 'A-Z'
```

Delete spaces

```bash
tr -d ' '
```

---

## wc

```bash
wc file.txt
```

Lines

```bash
wc -l
```

Words

```bash
wc -w
```

Characters

```bash
wc -c
```

---

## head

```bash
head file.txt
```

First 20 lines

```bash
head -20 file.txt
```

---

## tail

```bash
tail file.txt
```

Follow log

```bash
tail -f app.log
```

---

# Task 6: Useful Patterns and One-Liners

## Delete files older than 30 days

```bash
find /path -type f -mtime +30 -delete
```

---

## Count lines in all log files

```bash
wc -l *.log
```

---

## Replace text in multiple files

```bash
find . -name "*.txt" -exec sed -i 's/old/new/g' {} +
```

---

## Check if a service is running

```bash
systemctl is-active nginx
```

---

## Disk usage alert

```bash
df -h | awk '$5+0 > 80 {print $0}'
```

---

## Parse CSV

```bash
cut -d',' -f2 data.csv
```

---

## Parse JSON

```bash
jq '.name' file.json
```

---

## Tail log and filter errors

```bash
tail -f app.log | grep ERROR
```

---

## Find largest files

```bash
du -ah . | sort -rh | head -10
```

---

## List top memory-consuming processes

```bash
ps aux --sort=-%mem | head
```

---

# Task 7: Error Handling and Debugging

## Exit Codes

Success

```bash
exit 0
```

Failure

```bash
exit 1
```

Previous command status

```bash
echo $?
```

---

## set -e

Exit immediately on error.

```bash
set -e
```

---

## set -u

Treat undefined variables as errors.

```bash
set -u
```

---

## set -o pipefail

Detect failures in pipelines.

```bash
set -o pipefail
```

Example

```bash
grep foo file.txt | sort
```

Without `pipefail`, failure in `grep` may be ignored.

---

## set -x

Debug mode.

```bash
set -x
```

Shows every command before execution.

Disable:

```bash
set +x
```

---

## trap

Execute cleanup before exit.

```bash
cleanup() {
    echo "Cleaning up..."
}

trap cleanup EXIT
```

Useful for:

- Removing temporary files
- Closing resources
- Logging script termination

---

# Best Practices

- Always start scripts with a shebang.
- Quote variables (`"$VAR"`).
- Use meaningful variable names.
- Check command exit codes.
- Prefer `$(command)` over backticks.
- Use functions for reusable code.
- Enable `set -euo pipefail` for safer scripts.
- Use `shellcheck` to lint shell scripts.
- Add comments for complex logic.
- Test scripts before running in production.

---

# Common Keyboard Shortcuts

| Shortcut | Description |
|-----------|-------------|
| `Ctrl + C` | Stop running process |
| `Ctrl + Z` | Suspend process |
| `Ctrl + D` | Exit terminal/input |
| `Ctrl + R` | Search command history |
| `Ctrl + A` | Beginning of line |
| `Ctrl + E` | End of line |
| `!!` | Repeat previous command |
| `history` | Show command history |

---

# Quick Reference

```bash
#!/bin/bash

set -euo pipefail

read -p "Enter name: " NAME

if [ -n "$NAME" ]; then
    echo "Hello $NAME"
fi

for file in *.txt
do
    echo "$file"
done

myfunc() {
    local msg="$1"
    echo "$msg"
}

myfunc "Done"
```

---

````
