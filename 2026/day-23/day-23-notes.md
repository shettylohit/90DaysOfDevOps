## 1. What is a branch in Git?
A branch in Git is a lightweight, moveable pointer to a specific commit. 
It represents an independent line of development. When you create a branch, Git does not duplicate your files; it simply creates a new reference pointer to the current commit snapshot.
------------------------------
## 2. Why use branches instead of committing to main?
Committing everything directly to main makes the codebase unstable and disrupts team collaboration. Branches solve this by providing isolation

* Protects Production: The main branch remains clean, thoroughly tested, and always ready to deploy.
* Parallel Work: Multiple developers can work on different features (e.g., login-page and bug-fix) at the same time without overwriting each other's code.
* Safe Experimentation: You can try risky ideas in a separate branch. If they fail, you simply delete the branch without hurting the stable code.
* Code Reviews: Branches allow teams to use Pull Requests (PRs) to review, discuss, and test code before merging it into main. [11, 12, 13, 14, 15] 

------------------------------
## 3. What is HEAD in Git?
HEAD is a special pointer that tells Git which branch you are currently working on. 

* Think of it as a "You Are Here" marker on a map.
* When you commit, Git creates a new snapshot and moves both your current branch pointer and HEAD forward together.
* If you switch to another branch, HEAD moves to point to that new branch. 

------------------------------
## 4. What happens to your files when you switch branches?
When you switch branches (using git switch <branch> or git checkout <branch>), Git updates your local directory to match the snapshot of the branch you are moving to.

* File Changes: Git physically modifies, deletes, or adds files in your project folder so your workspace looks exactly like that branch's last commit. 
* Uncommitted Work: If you have unsaved changes in your workspace that conflict with the branch you are switching to, Git will block the switch and warn you.
* You must either commit those changes, stash them (git stash), or discard them before switching. [29, 30, 31, 32] 

------------------------------
