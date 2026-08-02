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
 ## 5. What is the difference between origin and upstream?
origin: This is your personal copy of the repository hosted on a server (like GitHub). 
It is the repository you cloned or created, and you have full permission to push your code changes to it.

upstream: This is the original, authoritative repository created by someone else that you cloned or "forked" your copy from. 
You usually only have permission to pull updates from it, not push code directly to it

-----------------------------

## 6. What is the difference between git fetch and git pull
The fundamental difference is that git fetch only downloads data, while git pull downloads data AND immediately merges it into your local files.


| Feature | `git fetch` | `git pull` |
| :--- | :--- | :--- |
| **What it does** | Downloads new history from the remote server. | Downloads new history and combines it with your local work. |
| **Changes your files?** | ❌ No. Your local files remain completely untouched. | Yes. It modifies your local files to match the remote server. |
| **Is it safe?** | 100% Safe. It will never overwrite your changes or cause conflicts. | ⚠️ Risk of conflicts. It can trigger merge conflicts that you must fix immediately. |
| **When to use** | When you want to see what your teammates have done without disrupting your own work. | When you want to update your current branch with the latest remote changes right away. |

----------------------------

## 7. What is the difference between clone and fork?
The primary difference is where the copy lives and your level of ownership. 

* Fork: A server-side copy of a repository that lives entirely on your remote hosting service (like GitHub or GitLab). It is a copy created under your personal account. You have full administrative control over this online copy.
* Clone: A local copy of a remote repository downloaded onto your physical computer. Cloning creates a local development workspace on your laptop, allowing you to edit files, create commits, and test code locally.

------------------------------
## 8. When would you clone vs. fork?

* Contributing to Open Source: You want to fix a bug or add a feature to a public project where you do not have direct write access (write permissions). 
* Starting a New Project from an Old One: You want to use an existing open-source project as a foundation to build your own separate, independent software product. 

## Use Clone when:

* Starting Daily Work: You already own a repository (or your team does), and you need a local copy on your laptop to start writing code.
* Downloading Code to Run It: You just want to use the software, run the project locally, or inspect the codebase without intending to change it on the remote server. 

### Note: In an open-source workflow, you usually do both—you fork the original repository on GitHub first, and then you clone your fork down to your computer. 
------------------------------
## 9. How to keep your fork in sync with the original repository
To pull updates from the original project into your fork, you must link your local repository to the original project as a secondary remote called upstream. 
## Step 1: Add the original repository as upstream 
Run this once inside your local project terminal (replace the URL with the original creator's repository link): 

git remote add upstream <github_repo_link>

## Step 2: Fetch the latest changes from the original project
Download all the new commits and branches from the original repository: 

git fetch upstream

## Step 3: Merge the changes into your local main branch 
Switch to your local main branch and pull the upstream updates into it: 

git switch main
git merge upstream/main

## Step 4: Update your online fork (origin)
Push your newly updated local main branch up to your GitHub profile so your online fork is perfectly synchronized 

git push origin main

------------------------------
