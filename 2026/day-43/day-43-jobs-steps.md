name: Multiple jobs

on: push
  # workflow_dispatch:
env:    ## WorkFlow LEVEL ENV
  APP_NAME: myapp

jobs:
  build:
    env:
        ENVIRONMENT: staging  ## Job LEVEL ENV
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7
      - name: Build
        env:
            VERSION: 1.0.0
        run: |
          echo "Building Application"
      - name: Print Env
        run: |
          echo $APP_NAME
          echo $ENVIRONMENT
          echo $VERSION

  test:
    name: Test
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7
      - name: Test
        run: |
          echo "Testing Application"
  deploy:
    name: deploy
    needs: Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7
      - name: Deploy
        run: |
          echo "Deploying application"
  print:
    name: Printing ENV
    runs-on: ubuntu-latest
    steps:
      - name: Print all env
        run: |
          echo $APP_NAME
          echo $ENVIRONMENT
          echo $VERSION

  date_job:
    name: Printing date
    runs-on: ubuntu-latest
    outputs:
        current_date: ${{ steps.time.outputs.date }}

    steps:
        - name: Print Current date
          id: time
          run: echo "date=$(date)" >> "$GITHUB_OUTPUT"

  print_date:
    name: Print date output from previous job
    runs-on: ubuntu-latest
    needs: date_job

    steps:
        - name: Print the date afrom previous job
          run: echo "Date from previous job is ${{ needs.date_job.outputs.current_date }}"

#A step that only runs when the branch is main

  step_function:
    name: Steps run only for main branch 
    runs-on: ubuntu-latest
    steps:
      - name: Run steps on main branch
        if: github.ref == 'refs/heads/master'
        run: echo "Deploying from main branch"

  fail_function:
    name: Steps run only if previous step fails
    runs-on: ubuntu-latest
    steps:
      - name: Successful step
        run: echo "This step runs first"

      - name: Build application
        run: exit 1

      - name: Run only if previous step failed
        if: failure()
        run: echo "The previous step failed!"


  contunue_on_error:
    name: Steps run even if previous step fails
    runs-on: ubuntu-latest
    steps:
      - name: First step
        run: echo "Starting build"

      - name: Step that may fail
        continue-on-error: true
        run: |
          echo "Running a command that will fail"
          exit 1

      - name: Next step
        run: echo "This step still runs!"

      - name: Final step
        run: echo "Workflow continues successfully"

  lint:
    name: Lint Job
    runs-on: ubuntu-latest
    steps:
      - name: Lint Job
        run: echo "Linting the code"

  test:
    name: Test Job
    runs-on: ubuntu-latest
    steps:
      - name: Test Job
        run: echo "Testing the code"


  summary:
    name: Summary Job
    needs: ["lint", "test"]
    runs-on: ubuntu-latest
    steps:
      - name: Main branch push
        if: github.ref == 'refs/heads/master'
        run: echo "This is a push to the master branch"

      - name: Feature branch push
        if: github.ref == 'refs/heads/feature'
        run: echo "This is a push to a feature branch"

      - name: Print commit message
        run: echo "Commit message ${{ github.event.head_commit.message }}"
