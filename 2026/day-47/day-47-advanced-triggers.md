.github/workflows/pr-lifecycle.yml

```
#  1: Pull Request Event Types
# Create .github/workflows/pr-lifecycle.yml that triggers on pull_request with specific activity types:

# Trigger on: opened, synchronize, reopened, closed
# Add steps that:
# Print which event type fired: ${{ github.event.action }}
# Print the PR title: ${{ github.event.pull_request.title }}
# Print the PR author: ${{ github.event.pull_request.user.login }}
# Print the source branch and target branch
# Add a conditional step that only runs when the PR is merged (closed + merged = true)
# Test it: create a PR, push an update to it, then merge it. Watch the workflow fire each time with a different event type.



name: PR Lifecycle

on:
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches:
      - master

jobs:
  print_events:
    name: Print PR Events
    runs-on: ubuntu-latest

    steps:
      - name: Checkout the code
        uses: actions/checkout@v4

      - name: Print event details
        run: |
          echo "Event type fired: ${{ github.event.action }}"
          echo "PR title: ${{ github.event.pull_request.title }}"
          echo "PR author: ${{ github.event.pull_request.user.login }}"
          echo "Source branch: ${{ github.event.pull_request.head.ref }}"
          echo "Target branch: ${{ github.event.pull_request.base.ref }}"

      - name: Check if PR is merged
        if: github.event.action == 'closed' && github.event.pull_request.merged == true
        run: |
          echo "New code merged to master branch"
          echo "PR successfully merged."

```
.github/workflows/pr-checks.yml

```
# Trigger on pull_request to main
# Add a job file-size-check that:
# Checks out the code
# Fails if any file in the PR is larger than 1 MB
# Add a job branch-name-check that:
# Reads the branch name from ${{ github.head_ref }}
# Fails if it doesn't follow the pattern feature/*, fix/*, or docs/*
# Add a job pr-body-check that:
# Reads the PR body: ${{ github.event.pull_request.body }}
# Warns (but doesn't fail) if the PR description is empty


name: PR Checks

on:
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  file-size-check:
    name: file-size-check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0 # need history to diff against the base commit

      - name: Fail if any changed file is larger than 1 MB
        env:
          BASE_SHA: ${{ github.event.pull_request.base.sha }}
          HEAD_SHA: ${{ github.event.pull_request.head.sha }}
        run: |
          limit=$((1024 * 1024))
          failed=0

          # Files added/modified/renamed in the PR (deleted files are skipped)
          while IFS= read -r -d '' file; do
            size=$(stat -c%s "$file")
            if [ "$size" -gt "$limit" ]; then
              echo "::error file=$file::$file is $size bytes (limit: $limit bytes / 1 MB)"
              failed=1
            fi
          done < <(git diff --name-only -z --diff-filter=d "$BASE_SHA...$HEAD_SHA")

          if [ "$failed" -eq 1 ]; then
            echo "One or more files exceed 1 MB."
            exit 1
          fi
          echo "All changed files are within the 1 MB limit."

  branch-name-check:
    name: branch-name-check
    runs-on: ubuntu-latest
    steps:
      - name: Validate branch name
        env:
          HEAD_REF: ${{ github.head_ref }}
        run: |
          echo "Branch: $HEAD_REF"
          if [[ "$HEAD_REF" =~ ^(feature|fix|docs)/.+ ]]; then
            echo "Branch name is valid."
          else
            echo "::error::Branch '$HEAD_REF' is invalid. Use feature/*, fix/*, or docs/*."
            exit 1
          fi

  pr-body-check:
    name: pr-body-check
    runs-on: ubuntu-latest
    steps:
      - name: Warn if PR description is empty
        env:
          PR_BODY: ${{ github.event.pull_request.body }}
        run: |
          # Strip all whitespace so a body of only spaces/newlines counts as empty
          trimmed=$(echo "$PR_BODY" | tr -d '[:space:]')
          if [ -z "$trimmed" ]; then
            echo "::warning::This PR has no description. Please explain what changed and why."
          else
            echo "PR description found."
          fi
```
.github/workflows/scheduled-tasks.yml

```
name: Scheduled Tasks

on:
  schedule:
    - cron: '30 2 * * 1'   # Every Monday at 02:30 UTC
    - cron: '0 */6 * * *'  # Every 6 hours (00:00, 06:00, 12:00, 18:00 UTC)
  workflow_dispatch:        # Manual runs for testing

permissions:
  contents: read

jobs:
  scheduled-job:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    env:
      # Set a repo variable HEALTH_URL (Settings > Secrets and variables > Actions > Variables)
      HEALTH_URL: ${{ vars.HEALTH_URL || 'https://example.com' }}
      SCHEDULE: ${{ github.event.schedule }}
    steps:
      - name: Show which schedule triggered this run
        run: |
          echo "Event:    ${{ github.event_name }}"
          echo "Schedule: ${SCHEDULE:-<none - manually triggered>}"

          case "$SCHEDULE" in
            "30 2 * * 1")  echo "Running the weekly Monday 02:30 UTC job" ;;
            "0 */6 * * *") echo "Running the 6-hourly job" ;;
            *)             echo "Not a scheduled run" ;;
          esac

      - name: Health check
        run: |
          echo "Checking $HEALTH_URL"
          status=$(curl --silent --show-error --location \
            --output /dev/null \
            --write-out '%{http_code}' \
            --max-time 10 \
            --retry 3 --retry-delay 5 --retry-all-errors \
            "$HEALTH_URL") || status="000"

          echo "HTTP status: $status"

          if [ "$status" -eq 200 ]; then
            echo "Health check passed."
          else
            echo "::error::Health check failed for $HEALTH_URL (HTTP $status)"
            exit 1
          fi
```
.github/workflows/smart-triggers.yml

```
name: Smart Triggers (paths-ignore)

on:
  push:
    branches:
      - main
      - 'release/*'
    paths-ignore:
      - '*.md'       # Markdown files in the repo root only
      - 'docs/**'    # Anything under docs/

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7

      - name: Show what triggered this run
        run: |
          echo "Branch: ${{ github.ref_name }}"
          echo "Triggered because at least one changed file is NOT a doc"
```
.github/workflows/tests.yml

```
name: Run Tests   # deploy-after-tests.yml matches on this exact name

on:
  push:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7

      # Replace with your real test command (npm test, pytest, go test ./..., etc.)
      - name: Run tests
        run: |
          echo "Running tests for ${{ github.sha }}..."
          echo "All tests passed."
```
.github/workflows/deploy-after-tests.yml

```
name: Deploy After Tests

on:
  workflow_run:
    workflows: ["Run Tests"]   # must match the `name:` in tests.yml, not the filename
    types: [completed]
    branches: [main]           # only deploy when the tested push was to main

permissions:
  contents: read

jobs:
  deploy:
    name: deploy
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    steps:
      # workflow_run executes in the context of the default branch,
      # so explicitly check out the exact commit that was tested.
      - uses: actions/checkout@v7
        with:
          ref: ${{ github.event.workflow_run.head_sha }}

      - name: Deploy
        env:
          HEAD_BRANCH: ${{ github.event.workflow_run.head_branch }}
          HEAD_SHA: ${{ github.event.workflow_run.head_sha }}
        run: |
          echo "Tests succeeded on $HEAD_BRANCH ($HEAD_SHA)"
          echo "Deploying..."
          # Add your real deploy steps here

  skipped-notice:
    name: skipped-notice
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion != 'success' }}
    steps:
      - name: Warn and stop
        env:
          CONCLUSION: ${{ github.event.workflow_run.conclusion }}
          RUN_URL: ${{ github.event.workflow_run.html_url }}
        run: |
          echo "::warning::Deployment skipped: 'Run Tests' finished with '$CONCLUSION'. See $RUN_URL"
          exit 0
```

.github/workflows/external-trigger.yml

```
name: External Trigger

on:
  repository_dispatch:
    types: [deploy-request]

permissions:
  contents: read

jobs:
  handle-dispatch:
    runs-on: ubuntu-latest
    env:
      # Passed via env (not inlined in the script) because the payload is external input
      TARGET_ENV: ${{ github.event.client_payload.environment }}
    steps:
      - name: Print event details
        run: |
          echo "Event type:  ${{ github.event.action }}"
          echo "Environment: ${TARGET_ENV:-<not provided>}"

      - name: Print full client payload
        env:
          PAYLOAD: ${{ toJSON(github.event.client_payload) }}
        run: echo "$PAYLOAD"

      - name: Validate environment
        run: |
          case "$TARGET_ENV" in
            staging|production)
              echo "Deploy request accepted for $TARGET_ENV" ;;
            *)
              echo "::error::Invalid or missing environment '$TARGET_ENV' (expected staging or production)"
              exit 1 ;;
          esac
```
