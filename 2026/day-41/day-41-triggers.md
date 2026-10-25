name: Hello

on:
  # pull_request: # Trigger for pull request 
  #   types: [opened, synchronize]
  #   branches:
  #     - master

  workflow_dispatch:

  # push:   # Trigger when pusged to main branch 
  #   branches:
  #     - master

  # schedule:   # Cron trigger every 15 Min 
  #   - cron: '*/15 * * * *'
  # workflow_dispatch:
  #   inputs:
  #     run-tests:
  #       description: "Run tests?"
  #       type: boolean
  #       required: true

  #     test-type:
  #       description: "Type of test to run"
  #       type: choice
  #       options:
  #         - unit
  #         - integration
  #         - all
  #       required: true

  #     environment:
  #       description: "Choose an environment"
  #       type: environment
  #       required: true

  #     build-number:
  #       description: "Custom build number"
  #       type: number
  #       required: false

  #     message:
  #       description: "Additional message"
  #       type: string
  #       required: false
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
