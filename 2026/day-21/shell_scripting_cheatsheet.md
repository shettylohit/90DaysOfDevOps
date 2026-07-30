Yes. A tabular format is often easier to scan during interviews or while writing scripts. Here's a concise version you can use as `shell_scripting_cheatsheet.md`.

````markdown
# Shell Scripting Cheat Sheet

---

# 1. Basics

| Topic | Syntax | Description | Example |
|-------|--------|-------------|---------|
| Shebang | `#!/bin/bash` | Specifies the Bash interpreter | `#!/bin/bash` |
| Make executable | `chmod +x script.sh` | Gives execute permission | `chmod +x script.sh` |
| Run script | `./script.sh` | Runs executable script | `./script.sh` |
| Run with bash | `bash script.sh` | Runs without execute permission | `bash script.sh` |
| Comment | `#` | Single-line comment | `# This is a comment` |
| Variable | `NAME="John"` | Declare variable | `echo "$NAME"` |
| Read input | `read` | Reads user input | `read -p "Name: " NAME` |
| Script name | `$0` | Current script | `echo $0` |
| First argument | `$1` | First CLI argument | `echo $1` |
| Number of args | `$#` | Total arguments | `echo $#` |
| All args | `$@` | All arguments | `echo "$@"` |
| Exit status | `$?` | Previous command status | `echo $?` |

---

# 2. String Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `=` | Equal | `[ "$a" = "$b" ]` |
| `!=` | Not equal | `[ "$a" != "$b" ]` |
| `-z` | Empty string | `[ -z "$name" ]` |
| `-n` | Non-empty string | `[ -n "$name" ]` |

---

# 3. Integer Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `-eq` | Equal | `[ $a -eq $b ]` |
| `-ne` | Not equal | `[ $a -ne $b ]` |
| `-lt` | Less than | `[ $a -lt 10 ]` |
| `-gt` | Greater than | `[ $a -gt 10 ]` |
| `-le` | Less than or equal | `[ $a -le 10 ]` |
| `-ge` | Greater than or equal | `[ $a -ge 10 ]` |

---

# 4. File Test Operators

| Operator | Meaning | Example |
|----------|---------|---------|
| `-f` | Regular file | `[ -f file.txt ]` |
| `-d` | Directory | `[ -d folder ]` |
| `-e` | Exists | `[ -e file ]` |
| `-r` | Readable | `[ -r file ]` |
| `-w` | Writable | `[ -w file ]` |
| `-x` | Executable | `[ -x script.sh ]` |
| `-s` | File not empty | `[ -s file.txt ]` |

---

# 5. Conditionals

## if

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

| Operator | Meaning | Example |
|----------|---------|---------|
| `&&` | AND | `cmd1 && cmd2` |
| `||` | OR | `cmd1 || echo "Failed"` |
| `!` | NOT | `if ! grep root file` |

## Case Statement

```bash
case "$1" in
start) echo "Start";;
stop) echo "Stop";;
restart) echo "Restart";;
*) echo "Invalid";;
esac
```

---

# 6. Loops

## For Loop

```bash
for item in A B C
do
    echo "$item"
done
```

## C-style For

```bash
for ((i=1;i<=5;i++))
do
    echo $i
done
```

## While Loop

```bash
while [ $count -le 5 ]
do
    ((count++))
done
```

## Until Loop

```bash
until [ $count -gt 5 ]
do
    ((count++))
done
```

| Keyword | Purpose |
|----------|---------|
| `break` | Exit loop |
| `continue` | Skip current iteration |

### Loop through files

```bash
for file in *.log
do
    echo "$file"
done
```

### Read file line by line

```bash
while read line
do
    echo "$line"
done < file.txt
```

---

# 7. Functions

| Topic | Example |
|-------|---------|
| Define | `hello(){ echo "Hi"; }` |
| Call | `hello` |
| Arguments | `echo "$1"` |
| Local variable | `local name="John"` |
| Return status | `return 0` |
| Return data | `echo "value"` |

Example

```bash
greet(){
    local name="$1"
    echo "Hello $name"
}

greet Alice
```

---

# 8. Text Processing Commands

## grep

| Command | Purpose |
|---------|---------|
| `grep "error" file` | Search |
| `grep -i error file` | Ignore case |
| `grep -r error .` | Recursive |
| `grep -c error file` | Count |
| `grep -n error file` | Line numbers |
| `grep -v error file` | Invert match |
| `grep -E "A|B"` | Extended regex |

---

## awk

| Command | Purpose |
|---------|---------|
| `awk '{print $1}' file` | First column |
| `awk -F, '{print $2}' file.csv` | Custom delimiter |
| `awk '/error/' file` | Pattern |
| `awk 'BEGIN{print "Start"}'` | BEGIN block |
| `awk 'END{print "Done"}'` | END block |

---

## sed

| Command | Purpose |
|---------|---------|
| `sed 's/a/b/' file` | Replace first |
| `sed 's/a/b/g' file` | Replace all |
| `sed '5d' file` | Delete line 5 |
| `sed -i 's/a/b/g' file` | Edit file |

---

## cut

| Command | Purpose |
|---------|---------|
| `cut -d',' -f2 file.csv` | Extract column |
| `cut -c1-5 file` | Extract characters |

---

## sort

| Command | Purpose |
|---------|---------|
| `sort file` | Alphabetical |
| `sort -n file` | Numeric |
| `sort -r file` | Reverse |
| `sort -u file` | Unique |

---

## uniq

| Command | Purpose |
|---------|---------|
| `uniq file` | Remove duplicates |
| `uniq -c file` | Count duplicates |

---

## tr

| Command | Purpose |
|---------|---------|
| `tr 'a-z' 'A-Z'` | Uppercase |
| `tr -d ' '` | Delete spaces |

---

## wc

| Command | Purpose |
|---------|---------|
| `wc -l file` | Count lines |
| `wc -w file` | Count words |
| `wc -c file` | Count characters |

---

## head / tail

| Command | Purpose |
|---------|---------|
| `head file` | First 10 lines |
| `head -20 file` | First 20 lines |
| `tail file` | Last 10 lines |
| `tail -f app.log` | Live monitoring |

---

# 9. Useful One-Liners

| Task | Command |
|------|---------|
| Delete files older than 30 days | `find . -type f -mtime +30 -delete` |
| Count lines in log files | `wc -l *.log` |
| Replace text in multiple files | `find . -name "*.txt" -exec sed -i 's/old/new/g' {} +` |
| Check service status | `systemctl is-active nginx` |
| Disk usage over 80% | `df -h | awk '$5+0>80{print}'` |
| Parse CSV | `cut -d',' -f2 file.csv` |
| Parse JSON | `jq '.name' file.json` |
| Tail logs for errors | `tail -f app.log \| grep ERROR` |
| Largest files | `du -ah . | sort -rh | head -10` |
| Top memory processes | `ps aux --sort=-%mem | head` |

---

# 10. Error Handling & Debugging

| Command | Purpose |
|---------|---------|
| `echo $?` | Previous exit code |
| `exit 0` | Success |
| `exit 1` | Failure |
| `set -e` | Exit on first error |
| `set -u` | Error on unset variable |
| `set -o pipefail` | Detect pipeline failures |
| `set -x` | Debug mode |
| `set +x` | Disable debug |
| `trap cleanup EXIT` | Run cleanup before exit |

Example:

```bash
#!/bin/bash
set -euo pipefail

cleanup() {
    echo "Cleaning up..."
}

trap cleanup EXIT
```

````
