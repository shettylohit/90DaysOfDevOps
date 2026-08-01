## What is the difference between git add and git commit?

git add: The staging area acts as a designated waiting room. 
Instead of forcing you to commit every single change you have made in your working directory all at once, 
the staging area allows you to use the git add command to explicitly select and group specific file changes together

git commit: 

## What does the staging area do? Why doesn't Git just commit directly?
The staging area is like a wating room to check for any mistake before committing, if there is any mistake we can revert back from the stating area  

## What information does git log show you?
git log shows all the info about the commit eg: name, email address, author, commit message  

## What is the .git/ folder and what happens if you delete it?
When you run git init in the top-level folder of your project, Git creates a hidden directory (typically .git) to track and manage files
Because it is hidden, you must use ls -a to see it
Deleting this hidden folder will completely delete the Git repository
Your working files will remain intact in your directory, but all version control history, branches, commits, and tracking will be permanently destroyed.

## What is the difference between a working directory, staging area, and repository?

1. The Working Directory This is your active sandbox. When you clone a project or create new files, you are manipulating the working directory.
   Git sees the modifications you make here, but it does not actively track them for the next version until you tell it to.
   Inspection: If you want to see exactly what you have modified in your working directory that has not been staged yet, you run git diff

2. The Staging Area (The Index) The staging area is a designated waiting room.
   Instead of saving all your working directory modifications at once, you use the git add command to explicitly select and group specific file changes together into the staging area
   Purpose: This intermediate step exists so you can craft Atomic Commits—keeping each commit focused on a single feature, fix, or idea, which makes your project easier to review and roll back if needed
   Inspection: If you want to see what is currently sitting in the staging area waiting to be committed (compared to your last commit), you run git diff --staged or git diff --cached

3. The Repository (The Commit History) A Git "Repo" is the workspace that tracks and manages your files' history
   When you run the git commit command, Git takes whatever is currently grouped in the staging area and permanently snapshots it into the repository's database
   Once data is committed here, it is safely stored in the .git folder as an object, allowing you to time-travel back to this exact version later
