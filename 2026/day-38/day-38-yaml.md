# Task 1: Key-Value Pairs

Create person.yaml that describes yourself with:

name
role
experience_years
learning (a boolean)


```
name: Lohit
role: System Engineer
experience_years: 5
learning: True
```
# Task 2: Lists

Add to person.yaml:

tools — a list of 5 DevOps tools you know or are learning
hobbies — a list using the inline format [item1, item2]

Write in your notes: What are the two ways to write a list in YAML?
```

tools:
  - Jenkins
  - Docker
  - Kubernetes
  - Terraform
  - Ansible

hobbies: ["Reading", "writing"]
```
# Task 3: Nested Objects

Create server.yaml that describes a server:

server with nested keys: name, ip, port
database with nested keys: host, name, credentials (nested further: user, password)

Verify: Try adding a tab instead of spaces — what happens when you validate it?
```

server:
  name: Server1
  ip: 10.15.4.108
  port: 22

database:
  host: localhost
  name: backup_database
  credentials:
    user: mark
    password: Mark@123
```
Task 4: Multi-line Strings

In server.yaml, add a startup_script field using:

The | block style (preserves newlines)
The > fold style (folds into one line)

Write in your notes: When would you use | vs >?

Literal Block Style (|) - The | symbol is used to preserve newlines exactly as they are written in the YAML file. This is useful when you want the text to be preserved verbatim.
```

Literal block: |
  This is a literal block.
  Newlines are preserved.
  So is indentation.
  Trailing spaces are preserved as well .
```

Folded Block Style (>) - The symbol is used to fold newlines into spaces. This is useful for text where you don't want hard line breaks to appear in the output.
```
folded block: >
  This is a folded block. Newlines become spaces. Indentation is not
  preserved. Trailing spaces are removed.
```
Task 6: Spot the Difference

Read both blocks and write what's wrong with the second one:
```
# Block 1 - correct
name: devops
tools:
  - docker
  - kubernetes

# Block 2 - broken
name: devops
tools:
- docker
  - kubernetes
```

The spacing is an issue it should be
```

# Block 2 - broken
name: devops
tools:
- docker
- kubernetes
```
