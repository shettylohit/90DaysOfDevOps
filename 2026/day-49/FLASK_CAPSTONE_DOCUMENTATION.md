# Flask Capstone Project Documentation

## GitHub Actions CI/CD Pipeline & DevSecOps Implementation

| Item | Value |
|------|-------|
| **Project** | Flask Capstone |
| **Repository** | `github_actions_practice` / `github-actions-capstone` |
| **Application** | Python Flask |
| **Container Registry** | Docker Hub |
| **CI/CD Platform** | GitHub Actions |
| **Security Tools** | Trivy, GitHub Dependency Review |
| **Runtime** | Python 3.12 |

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Project Objectives](#2-project-objectives)
3. [Technology Stack](#3-technology-stack)
4. [Repository Structure](#4-repository-structure)
5. [Flask Application Setup](#5-flask-application-setup)
6. [Docker Configuration](#6-docker-configuration)
7. [GitHub Actions Fundamentals](#7-github-actions-fundamentals)
8. [Workflow 1 – Flask Application CI](#8-workflow-1--flask-application-ci)
9. [Workflow 2 – Reusable Build & Test](#9-workflow-2--reusable-build--test)
10. [Workflow 3 – Reusable Docker Build & Push](#10-workflow-3--reusable-docker-build--push)
11. [Workflow 4 – Pull Request Pipeline](#11-workflow-4--pull-request-pipeline)
12. [Workflow 5 – Main Branch Production Pipeline](#12-workflow-5--main-branch-production-pipeline)
13. [Workflow 6 – Scheduled Docker Health Check](#13-workflow-6--scheduled-docker-health-check)
14. [Docker Vulnerability Scanning with Trivy](#14-docker-vulnerability-scanning-with-trivy)
15. [Dependency Vulnerability Review](#15-dependency-vulnerability-review)
16. [SARIF Security Reporting](#16-sarif-security-reporting)
17. [GitHub Actions Permissions](#17-github-actions-permissions)
18. [Pin Actions to Commit SHAs](#18-pin-actions-to-commit-shas)
19. [GitHub Repository Secrets](#19-github-repository-secrets)
20. [GitHub Environments and Manual Approval](#20-github-environments-and-manual-approval)
21. [Workflow Execution Guide](#21-workflow-execution-guide)
22. [Pipeline Architecture](#22-pipeline-architecture)
23. [Troubleshooting](#23-troubleshooting)
24. [Final Project Checklist](#24-final-project-checklist)
25. [Important DevSecOps Concepts](#25-important-devsecops-concepts-learned)

---

## 1. Project Overview

The Flask Capstone project demonstrates how to build an automated CI/CD pipeline using GitHub Actions.

The project contains a simple Python Flask application packaged inside a Docker container.

GitHub Actions automates the following processes:

- Source code checkout.
- Python environment setup.
- Dependency installation.
- Automated testing using `pytest`.
- Docker image creation.
- Docker image publishing to Docker Hub.
- Container vulnerability scanning.
- Dependency vulnerability checking.
- Production deployment workflow.
- Scheduled application health checks.

The project also incorporates DevSecOps practices such as least-privilege permissions, dependency reviews, vulnerability scanning, and immutable action references.

The main objective is to understand how application development, testing, containerization, security, and deployment fit together in a real-world automation pipeline.

---

## 2. Project Objectives

The project is divided into the following tasks.

| Task | Description |
|------|-------------|
| Task 1 | Set up Flask application and Dockerfile |
| Task 2 | Create reusable build-and-test workflow |
| Task 3 | Create reusable Docker build-and-push workflow |
| Task 4 | Implement pull request pipeline |
| Task 5 | Implement main branch production pipeline |
| Task 6 | Create scheduled Docker health check |
| Task 7 | Add workflow status badges |
| Task 8 | Add Trivy image vulnerability scanning |
| Task 9 | Add dependency vulnerability review |
| Task 10 | Configure least-privilege permissions |
| Optional | Pin GitHub Actions to commit SHAs |
| Optional | Upload Trivy SARIF reports to GitHub Security |

---

## 3. Technology Stack

| Technology | Purpose |
|------------|---------|
| Python 3.12 | Application runtime |
| Flask 3.1.2 | Web application framework |
| pytest | Automated testing |
| Docker | Application containerization |
| Docker Hub | Container image registry |
| GitHub Actions | CI/CD automation |
| Trivy | Container vulnerability scanning |
| Dependency Review | Dependency vulnerability detection |
| SARIF | Standard security findings format |
| GitHub Environments | Production deployment protection |

---

## 4. Repository Structure

Recommended repository structure:

```text
github_actions_practice/
│
├── .github/
│   └── workflows/
│       ├── py_flask_app.yml
│       ├── reusable-build-test.yml
│       ├── reusable-docker.yml
│       ├── pr-pipeline.yml
│       ├── main-pipeline.yml
│       └── health-check.yml
│
├── python_flask/
│   ├── app.py
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── test_app.py
│   ├── templates/
│   └── static/
│
├── README.md
└── FLASK_CAPSTONE_DOCUMENTATION.md
```

The Flask application is maintained inside `python_flask`, while GitHub Actions workflow definitions are maintained inside `.github/workflows`.

---

## 5. Flask Application Setup

### `app.py`

The Flask application exposes a basic health endpoint.

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "message": "Flask Capstone Application"
    })

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy"
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

#### Explanation

- `Flask(__name__)` initializes the Flask application.
- `/` provides the home endpoint.
- `/health` provides the health-check endpoint.
- `0.0.0.0` allows the application to accept connections from outside the container.
- Port `5000` is used by the Flask development server.

### `requirements.txt`

```text
Flask==3.1.2
```

This file contains the Python dependencies required by the application.

### `test_app.py`

```python
from app import app

def test_home():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200

def test_health():
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"
```

#### Explanation

The tests use Flask's built-in test client.

They verify:

- The home endpoint responds successfully.
- The health endpoint responds with HTTP 200.
- The health response contains the expected status.

---

## 6. Docker Configuration

### `python_flask/Dockerfile`

```dockerfile
FROM python:3.12-alpine

WORKDIR /pyapp

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

### Dockerfile explanation

| Instruction | Explanation |
|-------------|-------------|
| `FROM` | Selects Python base image |
| `WORKDIR` | Sets the container working directory |
| `COPY requirements.txt` | Copies dependency manifest |
| `RUN pip install` | Installs Python dependencies |
| `COPY . .` | Copies application source |
| `EXPOSE` | Documents application port |
| `CMD` | Starts the Flask application |

> **Important:** Docker build context must be `./python_flask`, because the Dockerfile and requirements file are located inside that directory.

Example local build:

```bash
docker build -t flask-capstone:latest ./python_flask
```

Run locally:

```bash
docker run -d \
  -p 5000:5000 \
  --name flask-capstone \
  flask-capstone:latest
```

Test:

```bash
curl http://localhost:5000/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

---

## 7. GitHub Actions Fundamentals

Before examining the workflows, understand these important concepts.

### Workflow

A workflow is an automated process defined in a YAML file inside `.github/workflows`.

### Trigger

A trigger determines when a workflow executes.

Examples:

```yaml
on:
  push:
    branches:
      - main
```

```yaml
on:
  pull_request:
    branches:
      - main
```

```yaml
on:
  workflow_dispatch:
```

```yaml
on:
  schedule:
    - cron: '0 */12 * * *'
```

### Job

A job is a collection of steps executed on a GitHub Actions runner.

### Step

A step is an individual command or action within a job.

### Reusable workflow

A reusable workflow allows one workflow to call another workflow.

It is triggered using:

```yaml
on:
  workflow_call:
```

### `needs`

The `needs` keyword defines job dependencies.

Example:

```yaml
docker_build:
  needs: build_test
```

This means Docker build starts only after the build-and-test job succeeds.

### Secrets

Secrets store sensitive values such as Docker Hub credentials.

They are accessed using:

```yaml
${{ secrets.docker_token }}
```

---

## 8. Workflow 1 – Flask Application CI

**File:** `.github/workflows/py_flask_app.yml`

This workflow performs basic CI validation of the Flask application.

It checks out source code, installs Python, installs dependencies, and executes `pytest`.

```yaml
name: Flask App CI

on:
  push:
    branches:
      - main
    paths:
      - 'python_flask/**'
      - '.github/workflows/py_flask_app.yml'

  workflow_dispatch:

defaults:
  run:
    working-directory: python_flask

permissions:
  contents: read

jobs:
  code:
    name: Code Checkout and Test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout the code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest

      - name: Run pytest
        run: pytest -v
```

### Explanation

- The workflow executes when application files are pushed to `main`.
- `workflow_dispatch` enables manual execution.
- Checkout retrieves repository code.
- Setup Python configures Python 3.12.
- Dependencies are installed using `pip`.
- `pytest` executes the application tests.

This is a standalone CI workflow. The PR and main pipelines also call the reusable testing workflow described below.

---

## 9. Workflow 2 – Reusable Build & Test

**File:** `.github/workflows/reusable-build-test.yml`

This workflow provides reusable build-and-test functionality.

Instead of writing the same testing steps in multiple workflows, other workflows can call this one.

### Complete YAML

```yaml
name: Reusable Workflow for Flask Application

on:
  workflow_call:
    inputs:
      python_version:
        description: 'Python Version'
        type: string
        required: false
        default: '3.12'

      run_tests:
        description: 'Run Tests'
        type: boolean
        required: false
        default: true

    outputs:
      test_result:
        description: 'Test execution result'
        value: ${{ jobs.code.outputs.test_result }}

permissions:
  contents: read

jobs:
  code:
    name: Code Checkout and Test
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: python_flask

    outputs:
      test_result: ${{ steps.tests.outputs.test_result }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ inputs.python_version }}
          cache: pip
          cache-dependency-path: python_flask/requirements.txt

      - name: Install Dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest

      - name: Run pytest
        id: tests
        if: ${{ inputs.run_tests }}
        run: |
          set +e
          pytest -v
          result=$?

          if [ "$result" -eq 0 ]; then
            echo "test_result=passed" >> "$GITHUB_OUTPUT"
          else
            echo "test_result=failed" >> "$GITHUB_OUTPUT"
          fi

          exit "$result"

      - name: Tests Disabled
        id: skipped
        if: ${{ !inputs.run_tests }}
        run: echo "test_result=skipped" >> "$GITHUB_OUTPUT"
```

### Explanation

**`workflow_call`**

Allows another workflow to execute this workflow.

**`python_version`**

Controls the Python version.

**`run_tests`**

Determines whether `pytest` should execute.

**`outputs`**

Exposes the test result to the calling workflow.

**`GITHUB_OUTPUT`**

Passes values from a step to other steps or jobs.

The test result can be:

- `passed`
- `failed`
- `skipped`

The workflow still fails when `pytest` fails.

### Example usage

```yaml
build_test:
  uses: ./.github/workflows/reusable-build-test.yml
  with:
    python_version: '3.12'
    run_tests: true
```

---

## 10. Workflow 3 – Reusable Docker Build & Push

**File:** `.github/workflows/reusable-docker.yml`

This reusable workflow builds the Docker image and pushes it to Docker Hub.

It accepts two inputs:

- `image_name`
- `tag`

It also accepts two secrets:

- `docker_username`
- `docker_token`

### Complete YAML

```yaml
name: Reusable Workflow - Docker Build and Push

on:
  workflow_call:
    inputs:
      image_name:
        description: 'Docker Image Name'
        type: string
        required: true

      tag:
        description: 'Docker Image Tag'
        type: string
        required: true

    secrets:
      docker_username:
        required: true

      docker_token:
        required: true

    outputs:
      image_url:
        description: 'Full Docker Image URL'
        value: ${{ jobs.build.outputs.image_url }}

permissions:
  contents: read

jobs:
  build:
    name: Build and Push Image
    runs-on: ubuntu-latest

    outputs:
      image_url: ${{ steps.image.outputs.image_url }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Generate Short SHA
        id: vars
        run: |
          echo "short_sha=${GITHUB_SHA::7}" >> "$GITHUB_OUTPUT"

      - name: Log in to Docker Hub
        uses: docker/login-action@v4
        with:
          username: ${{ secrets.docker_username }}
          password: ${{ secrets.docker_token }}

      - name: Build and Push Docker Image
        uses: docker/build-push-action@v6
        with:
          context: ./python_flask
          file: ./python_flask/Dockerfile
          push: true
          tags: |
            ${{ secrets.docker_username }}/${{ inputs.image_name }}:${{ inputs.tag }}
            ${{ secrets.docker_username }}/${{ inputs.image_name }}:sha-${{ steps.vars.outputs.short_sha }}

      - name: Set Image URL
        id: image
        run: |
          echo "image_url=${{ secrets.docker_username }}/${{ inputs.image_name }}:${{ inputs.tag }}" >> "$GITHUB_OUTPUT"
```

### Explanation

**Docker login**

Authenticates GitHub Actions with Docker Hub.

**Docker build**

Builds the image using the Flask application directory.

**`push: true`**

Pushes the resulting image to Docker Hub.

**Image tags**

Two tags are created:

```text
flask-capstone:latest
flask-capstone:sha-<short-commit-hash>
```

**Workflow output**

The workflow exposes the full image URL to the calling workflow.

Example:

```text
shettylohit/flask-capstone:latest
```

### Why use two tags?

- `latest` identifies the latest published image.
- The SHA tag identifies the exact source commit used to create an image.

SHA tags are useful for traceability and rollback.

---

## 11. Workflow 4 – Pull Request Pipeline

**File:** `.github/workflows/pr-pipeline.yml`

This workflow runs when a pull request is opened or updated against the `main` branch.

Its purpose is to validate code before merging.

It performs:

1. Build and test.
2. Dependency vulnerability review.
3. PR summary.

It does **not** build or push Docker images.

### Complete YAML

```yaml
name: Pull Request Pipeline

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize

permissions:
  contents: read
  pull-requests: read

jobs:
  build_test:
    name: Build and Test
    uses: ./.github/workflows/reusable-build-test.yml
    with:
      python_version: '3.12'
      run_tests: true

  dependency_review:
    name: Check Dependencies for Vulnerabilities
    runs-on: ubuntu-latest

    steps:
      - name: Check Dependencies for Vulnerabilities
        uses: actions/dependency-review-action@v4
        with:
          fail-on-severity: critical

  pr-comment:
    name: PR Summary
    runs-on: ubuntu-latest
    needs:
      - build_test
      - dependency_review

    steps:
      - name: Print PR Summary
        run: |
          echo "PR checks passed for branch: ${{ github.head_ref }}"
```

### Explanation

**`pull_request`**

Runs when a PR targeting `main` is opened or updated.

**`build_test`**

Calls the reusable testing workflow.

**`dependency_review`**

Checks new or changed dependencies for known vulnerabilities.

**`fail-on-severity: critical`**

Fails the dependency review if a critical vulnerability is detected.

**`pr-comment`**

Runs only after both previous jobs succeed.

Despite the job name, this job currently prints a summary in the Actions logs. It does **not** create an actual GitHub PR comment.

> **Important:** The dependency review action requires GitHub dependency graph support and access to the pull request's dependency changes.

This workflow intentionally does not contain any Docker build or push job.

---

## 12. Workflow 5 – Main Branch Production Pipeline

**File:** `.github/workflows/main-pipeline.yml`

This workflow automates the production pipeline.

It runs when code is pushed to `main` or when manually triggered.

The workflow has four major stages:

1. Build and test.
2. Docker build and push.
3. Security scanning.
4. Production deployment.

### Complete YAML

```yaml
name: Main Branch Production Pipeline

on:
  push:
    branches:
      - main

  workflow_dispatch:

permissions:
  contents: read

jobs:

  # Job 1: Build and Test
  build_test:
    name: Build and Test
    uses: ./.github/workflows/reusable-build-test.yml
    with:
      python_version: '3.12'
      run_tests: true

  # Job 2: Docker Build and Push
  docker_build_push:
    name: Docker Build and Push
    needs: build_test
    uses: ./.github/workflows/reusable-docker.yml
    with:
      image_name: flask-capstone
      tag: latest
    secrets:
      docker_username: ${{ secrets.docker_username }}
      docker_token: ${{ secrets.docker_token }}

  # Job 3: Security Scan
  security_scan:
    name: Scan Docker Image for Vulnerabilities
    needs: docker_build_push
    runs-on: ubuntu-latest

    permissions:
      contents: read
      security-events: write

    steps:
      - name: Log in to Docker Hub
        uses: docker/login-action@v4
        with:
          username: ${{ secrets.docker_username }}
          password: ${{ secrets.docker_token }}

      - name: Scan Docker Image - SARIF
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ secrets.docker_username }}/flask-capstone:latest
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: '0'

      - name: Upload Trivy Results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: trivy-results.sarif

      - name: Enforce Vulnerability Policy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ secrets.docker_username }}/flask-capstone:latest
          format: table
          severity: CRITICAL,HIGH
          exit-code: '1'

  # Job 4: Deploy to Production
  deploy:
    name: Deploy to Production
    needs:
      - docker_build_push
      - security_scan

    runs-on: ubuntu-latest

    environment: production

    steps:
      - name: Deploy Docker Image
        env:
          IMAGE_URL: ${{ needs.docker_build_push.outputs.image_url }}
        run: |
          echo "Deploying image: $IMAGE_URL to production"
```

### Explanation

#### Job 1 – Build and Test

Runs the reusable build-and-test workflow.

If `pytest` fails, the remaining dependent jobs do not run.

#### Job 2 – Docker Build and Push

Runs after successful testing.

It builds the Flask Docker image and pushes it to Docker Hub.

#### Job 3 – Security Scan

Uses Trivy to inspect the published Docker image.

It performs two scans.

**SARIF scan**

Creates a machine-readable security report:

```text
trivy-results.sarif
```

**Enforcement scan**

Uses:

```yaml
severity: CRITICAL,HIGH
exit-code: '1'
```

If matching HIGH or CRITICAL vulnerabilities are detected, the job fails.

#### Job 4 – Deploy to Production

Runs only when both Docker publishing and security scanning succeed.

The job uses:

```yaml
environment: production
```

This connects the job to GitHub's `production` environment and its configured protection rules.

### Important deployment distinction

The current deployment step:

```bash
echo "Deploying image: $IMAGE_URL to production"
```

only prints a deployment message.

It does **not** actually deploy the Flask container to a production server.

To implement real deployment, you need a target environment such as a VM, Kubernetes cluster, or cloud container service, along with its deployment credentials and commands.

---

## 13. Workflow 6 – Scheduled Docker Health Check

**File:** `.github/workflows/health-check.yml`

This workflow periodically checks whether the Dockerized Flask application is healthy.

It runs every 12 hours and can also be started manually.

### Complete YAML

```yaml
name: Scheduled Docker Health Check

on:
  schedule:
    - cron: '0 */12 * * *'

  workflow_dispatch:

permissions:
  contents: read

jobs:
  health-check:
    name: Check Flask Container Health
    runs-on: ubuntu-latest

    steps:
      - name: Log in to Docker Hub
        uses: docker/login-action@v4
        with:
          username: ${{ secrets.docker_username }}
          password: ${{ secrets.docker_token }}

      - name: Pull Latest Docker Image
        run: |
          docker pull ${{ secrets.docker_username }}/flask-capstone:latest

      - name: Run Container and Check Health
        env:
          IMAGE: ${{ secrets.docker_username }}/flask-capstone:latest
        run: |
          docker run -d \
            --name flask-capstone-health \
            -p 5000:5000 \
            "$IMAGE"

          status=1

          for attempt in {1..10}; do
            if curl --fail http://localhost:5000/health; then
              status=0
              break
            fi

            sleep 2
          done

          if [ "$status" -eq 0 ]; then
            echo "Health check PASSED"
            echo "- Image: $IMAGE" >> "$GITHUB_STEP_SUMMARY"
            echo "- Status: PASSED" >> "$GITHUB_STEP_SUMMARY"
          else
            echo "Health check FAILED"
            echo "- Image: $IMAGE" >> "$GITHUB_STEP_SUMMARY"
            echo "- Status: FAILED" >> "$GITHUB_STEP_SUMMARY"
          fi

          echo "- Time: $(date)" >> "$GITHUB_STEP_SUMMARY"

          docker stop flask-capstone-health || true
          docker rm flask-capstone-health || true

          exit "$status"
```

### Explanation

**`schedule`**

```yaml
cron: '0 */12 * * *'
```

Runs every 12 hours at minute zero.

GitHub scheduled workflows use **UTC**.

**`workflow_dispatch`**

Allows manual execution from the GitHub Actions interface.

**`docker pull`**

Downloads the latest published Docker image.

**`docker run -d`**

Starts the application in detached mode.

**`curl`**

Tests the Flask `/health` endpoint.

**`GITHUB_STEP_SUMMARY`**

Creates a readable report inside the GitHub Actions run summary.

### Expected health check output

```text
Health check PASSED
```

Example summary:

```text
## Health Check Report

- Image: shettylohit/flask-capstone:latest
- Status: PASSED
- Time: ...
```

The workflow attempts cleanup whether the health check passes or fails.

---

## 14. Docker Vulnerability Scanning with Trivy

Trivy is an open-source security scanner.

It can inspect:

- Operating system packages.
- Python dependencies.
- Container image layers.
- Known CVEs.
- Misconfigurations and other supported security findings.

In this project, Trivy scans the published Flask Docker image.

### Important configuration

```yaml
- name: Scan Docker Image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: shettylohit/flask-capstone:latest
    format: table
    exit-code: '1'
    severity: CRITICAL,HIGH
```

### Configuration explanation

| Setting | Purpose |
|---------|---------|
| `image-ref` | Identifies the Docker image |
| `format` | Defines report format |
| `exit-code` | Controls failure behavior |
| `severity` | Selects vulnerability severity levels |

### Why scan before deployment?

A container image may contain vulnerable packages even if the application tests pass.

The Trivy job acts as a **security gate**.

The deployment job depends on the security scan, preventing deployment when the configured scan fails.

### Example vulnerability table

```text
Library       Vulnerability ID   Severity
------------  -----------------  --------
package-a     CVE-2025-XXXXX     HIGH
package-b     CVE-2025-YYYYY     CRITICAL
```

This is an illustrative example, not an actual scan result.

A successful scan means no matching findings caused the configured scan to fail. It does not guarantee the image is completely vulnerability-free.

---

## 15. Dependency Vulnerability Review

GitHub Dependency Review checks dependencies introduced or changed by a pull request.

It helps identify vulnerable dependencies before code is merged.

### Action

```yaml
- name: Check Dependencies for Vulnerabilities
  uses: actions/dependency-review-action@v4
  with:
    fail-on-severity: critical
```

### What does it check?

For example, suppose a developer changes `requirements.txt`:

```text
Flask==3.1.2
some-package==1.0.0
```

The dependency review action checks dependency changes against vulnerability information available through GitHub's dependency graph.

If a critical vulnerability is detected, the job fails.

### Dependency Review vs Trivy

| Feature | Dependency Review | Trivy |
|---------|-------------------|-------|
| Main purpose | Review dependency changes | Scan container images |
| Runs in | PR pipeline | Main pipeline |
| Checks CVEs | Yes | Yes |
| Scans Docker image | No | Yes |
| Can block PR | Yes | Not applicable |
| Can block deployment | Through pipeline design | Yes |

Both tools contribute to application security.

---

## 16. SARIF Security Reporting

SARIF stands for **Static Analysis Results Interchange Format**.

It is a standardized format for representing security findings.

Trivy can generate SARIF output:

```yaml
- name: Scan Docker Image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: shettylohit/flask-capstone:latest
    format: sarif
    output: trivy-results.sarif
```

The report can then be uploaded:

```yaml
- name: Upload Trivy Results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: trivy-results.sarif
```

### Required permissions

```yaml
permissions:
  contents: read
  security-events: write
```

### Where can you see the results?

Navigate to:

**GitHub Repository → Security → Code scanning**

The findings may include:

- CVE identifier.
- Vulnerable package.
- Severity.
- Affected version.
- Suggested fixed version, when available.

SARIF upload availability depends on repository visibility, Code Security entitlement, and repository configuration.

---

## 17. GitHub Actions Permissions

Permissions determine what a workflow can access through the GitHub token.

The recommended approach is the **principle of least privilege**.

### Basic permissions

```yaml
permissions:
  contents: read
```

This grants read access to repository contents.

### Pull request permissions

```yaml
permissions:
  contents: read
  pull-requests: read
```

This is suitable for workflows that need to inspect pull requests.

For actual PR comments, use:

```yaml
permissions:
  contents: read
  pull-requests: write
```

### Security reporting permissions

```yaml
permissions:
  contents: read
  security-events: write
```

This is needed for SARIF uploads.

### Why permissions matter

Without appropriate permissions:

- Checkout may fail.
- PR comments may fail.
- SARIF uploads may fail.
- Repository write operations may be denied.

Avoid granting write permissions when they are not required.

Remember that reusable workflows cannot elevate permissions beyond those granted by their caller.

---

## 18. Pin Actions to Commit SHAs

GitHub Actions can be referenced using tags:

```yaml
uses: actions/checkout@v4
```

However, tags can be moved by the action maintainer.

For stronger supply-chain security, pin actions to full commit SHAs.

Example:

```yaml
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

### Advantages

- Prevents unexpected changes caused by moving tags.
- Makes action versions reproducible.
- Improves supply-chain security.
- Helps with auditing.

### How to find a commit SHA

1. Open the action's GitHub repository.
2. Navigate to **Releases**.
3. Select the desired stable version.
4. Open the associated commit.
5. Copy the full 40-character SHA.
6. Replace the version tag in your YAML.

Example:

```yaml
# Tag-based reference
uses: actions/checkout@v4

# SHA-pinned reference
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

> Do not assume every example SHA corresponds to the newest release. Verify the SHA and version before using it.

Recommended references:

- <https://github.com/actions/checkout>
- <https://github.com/actions/setup-python>
- <https://github.com/docker/login-action>
- <https://github.com/docker/build-push-action>
- <https://github.com/aquasecurity/trivy-action>
- <https://github.com/actions/dependency-review-action>

---

## 19. GitHub Repository Secrets

Docker Hub credentials must be stored securely.

Navigate to:

**GitHub Repository → Settings → Secrets and variables → Actions**

Create the following repository secrets.

| Secret | Description |
|--------|-------------|
| `docker_username` | Docker Hub username |
| `docker_token` | Docker Hub personal access token |

### Generate Docker Hub token

1. Sign in to Docker Hub.
2. Open **Account Settings**.
3. Navigate to **Personal Access Tokens**.
4. Generate a new token.
5. Select **Read & Write** permissions.
6. Copy the token.
7. Save it in GitHub repository secrets.

### Use secrets in workflows

```yaml
username: ${{ secrets.docker_username }}
password: ${{ secrets.docker_token }}
```

- Never hardcode credentials in workflow YAML files.
- Never commit Docker Hub access tokens to Git.
- If a token is exposed, revoke it and generate a new one.

---

## 20. GitHub Environments and Manual Approval

GitHub Environments provide deployment protection.

In this project, the production job uses:

```yaml
environment: production
```

### Configure production environment

1. Open the GitHub repository.
2. Navigate to **Settings**.
3. Select **Environments**.
4. Create an environment named `production`.
5. Configure required reviewers if supported by your repository plan.
6. Save protection rules.

### What happens?

When the deployment job starts:

1. GitHub checks the environment protection rules.
2. If approval is required, the job waits.
3. An authorized reviewer approves or rejects the deployment.
4. After approval, the job continues.

This helps prevent unapproved production releases.

> **Important:** Environment approval protects the job, but it does not automatically deploy the container to a server.

---

## 21. Workflow Execution Guide

This section explains how to execute and verify each workflow.

### A. Run Flask CI

Push a change to the Flask application on the configured branch.

```bash
git add .
git commit -m "Update Flask application"
git push origin main
```

Navigate to:

**GitHub → Actions → Flask App CI**

Check whether `pytest` passes.

### B. Run reusable build and test

This workflow is called by the PR and main pipelines.

It can also be called from another workflow.

It is not normally started independently from the Actions tab because it uses `workflow_call`.

### C. Run reusable Docker build and push

This workflow is called from the main pipeline after successful testing.

Verify Docker Hub for:

```text
shettylohit/flask-capstone:latest
```

and:

```text
shettylohit/flask-capstone:sha-<short-hash>
```

### D. Test PR pipeline

Create a feature branch:

```bash
git checkout -b feature/test-pipeline
```

Make a small change and push:

```bash
git add .
git commit -m "Test PR pipeline"
git push origin feature/test-pipeline
```

Open a pull request targeting `main`.

Verify:

- Build and Test passes.
- Dependency Review runs.
- PR Summary executes only when both checks pass.
- No Docker push occurs.

### E. Test main pipeline

Merge a pull request into `main`, or push a commit directly if your repository policy permits it.

Verify the job order:

1. Build and Test.
2. Docker Build and Push.
3. Security Scan.
4. Deploy to Production.

### F. Test health check

Navigate to:

**GitHub → Actions → Scheduled Docker Health Check**

Click **Run workflow**.

Verify:

- Docker Hub login succeeds.
- Image pull succeeds.
- Container starts.
- `/health` returns HTTP 200.
- Container is stopped and removed.
- A report is written to the Actions summary.

### G. Test vulnerability scanning

Open the Trivy scan job.

Inspect the scan output and determine:

- Whether vulnerabilities were detected.
- Which packages are affected.
- Their severity.
- Whether fixed versions are available.
- Whether the security gate passed or failed.

Do not assume a scan passes just because the image built successfully.

---

## 22. Pipeline Architecture

The complete project architecture is represented below.

### Pull Request Pipeline

```text
Developer creates feature branch
             |
             v
       Opens Pull Request
             |
             v
      Build and Test
             |
             v
     Dependency Review
             |
             v
       PR Summary
             |
             v
       Ready to Merge
```

The PR pipeline does **not** build or push Docker images.

### Main Branch Pipeline

```text
        Merge to Main
             |
             v
       Build and Test
             |
             v
    Docker Build and Push
             |
             v
      Trivy Security Scan
             |
             v
     SARIF Report Upload
             |
             v
   HIGH/CRITICAL Enforcement
             |
             v
    Production Deployment
             |
             v
       Manual Approval
       (if configured)
             |
             v
       Deployment Job
```

The production deployment job is currently a demonstration step. Actual infrastructure deployment requires an additional deployment implementation.

### Scheduled Health Check

```text
      Every 12 Hours
             |
             v
      Docker Hub Login
             |
             v
       Pull Latest Image
             |
             v
       Start Container
             |
             v
      Wait and Check
             |
             v
      Curl /health
             |
       +-----+-----+
       |           |
       v           v
     PASSED      FAILED
       |           |
       +-----+-----+
             |
             v
       Cleanup Container
             |
             v
       Write Summary
```

---

## 23. Troubleshooting

### Problem 1: `requirements.txt` not found

**Error:**

```text
Could not open requirements file:
No such file or directory
```

**Cause:**

Docker is using the wrong build context.

**Solution:**

```yaml
with:
  context: ./python_flask
  file: ./python_flask/Dockerfile
```

### Problem 2: Docker Hub authentication failure

**Error:**

```text
401 Unauthorized:
access token has insufficient scopes
```

**Cause:**

The Docker Hub token does not have sufficient permissions.

**Solution:**

1. Generate a new Docker Hub token.
2. Grant **Read & Write** permissions.
3. Update the `docker_token` GitHub secret.
4. Rerun the workflow.

### Problem 3: Deployment working directory error

**Error:**

```text
No such file or directory:
./python_flask
```

**Cause:**

A global `working-directory` setting was applied to a job that does not need it.

**Solution:**

Remove unnecessary global defaults and set the working directory only in jobs that execute Flask commands.

### Problem 4: Empty image URL

**Output:**

```text
Deploying image:  to production
```

**Cause:**

The reusable workflow did not correctly expose its output.

**Solution:**

Verify all three output levels:

```yaml
outputs:
  image_url: ${{ jobs.build.outputs.image_url }}
```

```yaml
outputs:
  image_url: ${{ steps.image.outputs.image_url }}
```

```bash
echo "image_url=..." >> "$GITHUB_OUTPUT"
```

### Problem 5: Trivy cannot pull Docker image

**Possible causes:**

- Docker Hub login failed.
- Image name is incorrect.
- Repository is private and credentials are missing.
- Image was not pushed successfully.

Verify the image path and Docker Hub credentials.

### Problem 6: SARIF upload fails

**Possible causes:**

- Missing `security-events: write`.
- Code Security is unavailable or not enabled.
- SARIF file was not generated.
- SARIF report path is incorrect.

Check the Trivy scan output and GitHub repository security configuration.

### Problem 7: Health check fails

**Possible causes:**

- Flask application is not listening on `0.0.0.0`.
- Incorrect container port.
- Incorrect health endpoint.
- Container failed to start.
- Docker image is outdated.

Test locally:

```bash
docker run -d -p 5000:5000 flask-capstone:latest

curl http://localhost:5000/health
```

Inspect container logs:

```bash
docker logs flask-capstone
```

---

## 24. Final Project Checklist

### Application

- [ ] Flask application created.
- [ ] Health endpoint implemented.
- [ ] `requirements.txt` configured.
- [ ] `pytest` tests created.
- [ ] Dockerfile created.
- [ ] Docker image builds locally.

### CI/CD

- [ ] Standalone Flask CI workflow.
- [ ] Reusable build-and-test workflow.
- [ ] Reusable Docker build-and-push workflow.
- [ ] Pull request pipeline.
- [ ] Main branch pipeline.
- [ ] Scheduled health check.

### Docker

- [ ] Docker Hub account configured.
- [ ] GitHub Docker secrets configured.
- [ ] Docker image successfully pushed.
- [ ] `latest` tag available.
- [ ] SHA tag available.

### Security

- [ ] Trivy image scanning implemented.
- [ ] HIGH and CRITICAL severity configured.
- [ ] Dependency Review implemented.
- [ ] SARIF reporting configured.
- [ ] GitHub permissions restricted.
- [ ] Third-party actions reviewed and SHA-pinned.

### Production

- [ ] `production` environment created.
- [ ] Required reviewers configured if available.
- [ ] Deployment job depends on successful security scan.
- [ ] Actual deployment target configured if production deployment is required.

### Documentation

- [ ] `README.md` created.
- [ ] Workflow status badges added.
- [ ] Pipeline architecture documented.
- [ ] Project documentation added.

---

## 25. Important DevSecOps Concepts Learned

This project demonstrates several important DevOps and DevSecOps concepts.

| Concept | What you learned |
|---------|------------------|
| Continuous Integration | Automatically testing application changes |
| Continuous Delivery | Preparing verified application images for release |
| Reusable Workflows | Avoiding duplicated workflow logic |
| Docker | Packaging applications into containers |
| Docker Hub | Publishing and distributing container images |
| Workflow Dependencies | Controlling execution order with `needs` |
| Workflow Outputs | Sharing results between reusable workflows |
| GitHub Secrets | Securely storing credentials |
| Dependency Review | Checking changed dependencies for vulnerabilities |
| Container Scanning | Identifying known vulnerabilities in images |
| SARIF | Publishing structured security findings |
| Least Privilege | Restricting GitHub token permissions |
| SHA Pinning | Protecting against mutable action references |
| GitHub Environments | Controlling production deployments |
| Scheduled Workflows | Automating recurring health checks |

---

## Final Project Summary

The Flask Capstone project brings together application development, automated testing, Docker containerization, security scanning, and GitHub Actions automation.

The PR pipeline validates code and dependencies before merging.

The main branch pipeline builds and publishes Docker images, scans them for vulnerabilities, and gates the production deployment job.

The scheduled health-check workflow periodically validates the running container image.

Together, these workflows demonstrate the fundamentals of a modern CI/CD and DevSecOps implementation.

**Project outcome:** A Flask application with automated CI, reusable GitHub Actions workflows, Docker image publishing, security checks, and scheduled health monitoring.

---

## Documentation Maintenance Note

- The YAML examples in this document are reference configurations. Keep them synchronized with the actual files in your repository.
- The examples use `main` as the primary branch. If your repository still uses `master`, update the branch triggers accordingly.
- Action version tags such as `@v4` and `@master` should be replaced with verified full commit SHAs when applying the SHA-pinning security practice. Do not use an unverified SHA.
- Before treating this as a production deployment, configure a real deployment target and validate the deployment, rollback, monitoring, and secret-management procedures.
