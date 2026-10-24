# Day 39 - What Is CI/CD?

## Introduction

CI/CD stands for **Continuous Integration and Continuous Delivery/Deployment**. It automates the process of integrating code, testing applications, and delivering software.

The main goal of CI/CD is to make software releases faster, safer, and more reliable.

---

## Task 1: The Problem

### 1. What Can Go Wrong When 5 Developers Deploy Manually?

When five developers work on the same repository and deploy manually, several problems can occur:

- **Merge conflicts:** Developers may change the same files, causing conflicts.
- **Production bugs:** Code may be deployed without proper testing.
- **Human errors:** Developers may deploy the wrong version or forget important steps.
- **Environment differences:** Code may work on one computer but fail on the production server.
- **Downtime:** A failed deployment may make the application unavailable.
- **Dependency issues:** Different library versions may cause errors.
- **Slow releases:** Manual testing and deployment take time.
- **Rollback difficulties:** Restoring the previous working version may be complicated.

### 2. What Does "It Works on My Machine" Mean?

"It works on my machine" means that an application runs correctly on one developer's computer but fails on another computer or production server.

**Why is it a problem?**

Different environments may have different operating systems, dependency versions, configurations, or environment variables. These differences can cause the same code to behave differently.

**Solution:** Use consistent environments, automated testing, dependency management, and tools such as Docker.

### 3. How Many Times a Day Can a Team Safely Deploy Manually?

There is no fixed number of safe manual deployments per day. It depends on the application's complexity, testing process, and deployment procedures.

A small team may manage one or a few manual deployments per day. Frequent manual deployments increase repetitive work and the risk of human error.

With reliable CI/CD automation, teams can deploy many times a day.

**Conclusion:** Manual deployment can work for small projects, but automation makes frequent releases safer and more consistent.

---

## Task 2: CI vs CD

### 1. Continuous Integration (CI)

Continuous Integration is the practice of frequently merging code changes into a shared repository. Automated builds and tests run to detect problems early.

**What happens?**
- Developers push code.
- Automated builds and tests run.

**How often?**

On every push or pull request, depending on the configuration.

**What does it catch?**
- Build failures
- Test failures
- Integration problems

**Real-world example:**

Five developers work on a web application. Whenever a developer pushes code to GitHub, GitHub Actions runs automated tests. If a test fails, the team can fix it before releasing the code.

### 2. Continuous Delivery

Continuous Delivery extends CI by automatically building, testing, and preparing software so that it is always ready for release. Production deployment usually requires manual approval.

**What does delivery mean?**

It means the software has passed the required checks and is ready to deploy to production, even if the team chooses to wait.

**Real-world example:**

A developer pushes code to GitHub. The pipeline tests the application, builds a Docker image, and deploys it to staging. After approval, the team deploys the release to production.

### 3. Continuous Deployment

Continuous Deployment automatically deploys every code change to production once it passes all required checks, without requiring separate manual release approval.

**How is it different from Continuous Delivery?**

- **Continuous Delivery:** Software is ready for production, but a person usually decides when to release it.
- **Continuous Deployment:** Software is automatically released to production when all required conditions are satisfied.

**When do teams use it?**

Teams use it when they have reliable automated tests, monitoring, and safe deployment procedures.

**Real-world example:**

A software company automatically tests each code change, builds the application, and deploys it to production when every required check passes.

### CI vs Continuous Delivery vs Continuous Deployment

| Feature | Continuous Integration | Continuous Delivery | Continuous Deployment |
|---|---|---|---|
| Main goal | Integrate and validate code | Keep software ready for release | Automatically release validated changes |
| Automated tests | Yes | Yes | Yes |
| Build automation | Usually | Yes | Yes |
| Production deployment | Not required | Usually requires manual approval | Automatic |
| Manual release approval | Not applicable to CI itself | Usually required | Not required for each release |

### Remember

- **CI** = Integrate and test.
- **Continuous Delivery** = Keep software ready to release.
- **Continuous Deployment** = Automatically release validated changes.

---

## Task 3: Pipeline Anatomy

A CI/CD pipeline is a sequence of automated processes that takes code from a repository through testing, building, and delivery or deployment.

### 1. Trigger

A trigger is an event that starts the pipeline.

**Examples:**
- A developer pushes code to GitHub.
- A pull request is opened or updated.
- A scheduled workflow starts.
- Someone manually starts a workflow.

**Example:** A developer pushes code to the `main` branch, triggering the pipeline.

### 2. Stage

A stage is a logical phase of the pipeline that groups related work.

**Examples:**
- Build stage
- Test stage
- Package stage
- Deploy stage

**Example:** The test stage runs automated tests before the application proceeds to deployment.

### 3. Job

A job is a collection of steps executed by a runner. Jobs can run in parallel or sequentially, depending on their dependencies and configuration.

**Example:** A `run-tests` job installs dependencies and executes the application's test suite.

### 4. Step

A step is an individual command or action inside a job.

**Examples:**
- Check out source code.
- Install dependencies.
- Run unit tests.
- Build a Docker image.

**Example:** `npm test` runs tests in a Node.js application.

### 5. Runner

A runner is the machine or execution environment that runs a job's steps. It can be a hosted virtual machine or a self-hosted machine.

**Example:** A GitHub-hosted Ubuntu runner executes the test and build jobs.

### 6. Artifact

An artifact is a file or package produced during a pipeline run that can be stored or passed to later stages.

**Examples:**
- Compiled application files
- Test reports
- Build packages
- Docker images stored in a container registry

**Example:** The pipeline builds a Docker image, tags it with a version, and pushes it to a container registry so that the staging server can use it.

---

## Task 4: Draw a CI/CD Pipeline

### Scenario

A developer pushes code to GitHub. The application is tested, built into a Docker image, and deployed to a staging server.

### Pipeline Diagram

```text
Developer writes code
        |
        v
Push code to GitHub
        |
        v
+-------------------------+
| STAGE 1: SOURCE / CI    |
| Trigger pipeline        |
| Checkout source code    |
+-------------------------+
        |
        v
+-------------------------+
| STAGE 2: TEST           |
| Install dependencies    |
| Run automated tests     |
+-------------------------+
        |
        v
    Tests pass?
       /   \
     No     Yes
     |       |
     v       v
   Stop   +-------------------------+
 Pipeline | STAGE 3: BUILD          |
          | Build Docker image      |
          | Tag the image           |
          +-------------------------+
                    |
                    v
          +-------------------------+
          | PUBLISH IMAGE           |
          | Push image to registry  |
          +-------------------------+
                    |
                    v
          +-------------------------+
          | STAGE 4: DEPLOY         |
          | Pull Docker image       |
          | Deploy to staging       |
          +-------------------------+
                    |
                    v
          +-------------------------+
          | STAGE 5: VERIFY         |
          | Run smoke tests         |
          | Check application health|
          +-------------------------+
                    |
                    v
          App running on staging
