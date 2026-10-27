# Multiple Runner 

name: Hello
on:
  workflow_dispatch:
jobs:
  greet:
    name: Greet
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, ubuntu-20.04, windows-latest]
        images: [hello-world, alpine]
        exclude:     # Excluding specific combination
          - images: alpine
            os: windows-latest

    runs-on: '${{ matrix.os }}'
    environment: ${{ inputs.environment }}


    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Print greeting
        run: echo "Hello from GitHub Actions! Part 2"

      - name: Print PR branch
        run: 'echo "PR check running for branch: ${{ github.head_ref }}"'

      - name: Print workflow inputs
        run: |
          echo "Run tests: ${{ inputs.run-tests }}"
          echo "Test type: ${{ inputs.test-type }}"
          echo "Environment: ${{ inputs.environment }}"
          echo "Build number: ${{ inputs.build-number }}"
          echo "message: ${{ inputs.message }}"


      # Perform action based on Input
      - name: Run tests (if selected)
        if: ${{ inputs.run-tests == true }}
        run: echo "Testing ........."


      # Deploy to the chosen environment
      - name: Deploy to ${{ inputs.environment }}
        run: echo "Deploying to ${{ inputs.environment }}"

# fail-fast: false allows all jobs to complete regardless of failures.
# fail-fast: true means if one matrix job fails, GitHub Actions cancels all the other matrix jobs that are still running.
      - name: Simulate failure
        if: matrix.os == 'ubuntu-latest' && matrix.images == 'hello-world'
        run: |
          echo "Intentionally failing this matrix job"
          exit 1
-----------------------------------------------------------------------------------------------------------------------------

name: Multiple jobs

on:
  workflow_dispatch:
jobs:
  job-1:
    name: Job-1
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7
      - name: Print info
        run: |
          echo "OS Name: $(uname -s)"
          echo "Runner Hostname: $(hostname)"
          echo "Current User: $(whoami)"
      - name: Print version of installed apps
        run: |
          echo "Docker version: $(docker --version)"
          echo "Python version: $(python --version)"
          echo "Node version: $(node --version)"
          echo "Git version: $(git --version)"
   job-2:
     name: Job-2
     runs-on: windows-latest
     steps:
       - name: Checkout
         uses: actions/checkout@v7
       - name: Print info
         run: |
           echo "OS Name: $(uname -s)"
           echo "Runner Hostname: $(hostname)"
           echo "Current User: $(whoami)"
   job-3:
     name: Job-3
     runs-on: macos-latest
     steps:
       - name: Checkout
         uses: actions/checkout@v7
       - name: Print info
         run: |
           echo "OS Name: $(uname -s)"
           echo "Runner Hostname: $(hostname)"
           echo "Current User: $(whoami)"
-----------------------------------------------------------------------------------------------------
name: Self Hosted jobs

on:
  workflow_dispatch:
jobs:
  job-1:
    name: Job-1
    # runs-on: self-hosted
    runs-on: [self-hosted, my-linux-runner]
    steps:
      - name: Checkout
        uses: actions/checkout@v7
      - name: Print info
        run: |
          echo "OS Name: $(uname -s)"
          ls -l
          touch /home/ec2-user/test1.txt
