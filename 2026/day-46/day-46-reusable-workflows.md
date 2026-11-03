reusable-build.yml
```

name: Reusable Workflow

on:
  workflow_call:
    inputs:
      app_name:
        description: 'Name of the App'
        type: string
        required: true

      environment:
        description: 'Environment of the App'
        type: string
        required: true
        default: 'staging'

    secrets:
      docker_token:
        description: 'Docker Token'
        required: true

    outputs:
      build_version:
        description: 'Generated build version'
        value: ${{ jobs.reusable_build.outputs.build_version }}

jobs:
  reusable_build:
    name: Reusable Build
    runs-on: ubuntu-latest

    outputs:
      build_version: ${{ steps.version.outputs.build_version }}

    steps:
      - name: Checkout the code
        uses: actions/checkout@v4

      - name: Print app name
        run: |
          echo "Building ${{ inputs.app_name }} for ${{ inputs.environment }}"

      - name: Check Docker token
        env:
          SECRET_MESSAGE: ${{ secrets.docker_token }}
        run: |
          if [[ -n "$SECRET_MESSAGE" ]]; then
            echo "Docker token is set: true"
          else
            echo "Docker token is set: false"
          fi

      - name: Generate build version
        id: version
        run: |
          BUILD_VERSION="v1.0-${GITHUB_SHA::7}"
          echo "Build version: $BUILD_VERSION"
          echo "build_version=$BUILD_VERSION" >> "$GITHUB_OUTPUT"


```
call-build.yml
```

name: Calling Reusable Workflow

on: push

jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      app_name: "my-web-app"
      environment: "production"
    secrets:
      docker_token: ${{ secrets.DOCKER_TOKEN }}

  print_version:
    name: Print Build Version
    runs-on: ubuntu-latest
    needs: build

    steps:
      - name: Display build version
        run: |
          echo "Build version from reusable workflow: ${{ needs.build.outputs.build_version }}"

```
.github/actions/setup-and-greet/action.yml

```

name: Setup and Greet
description: Greets a person in the chosen language, prints the date and runner OS, and sets an output.

inputs:
  name:
    description: Name of the person to greet
    required: true
  language:
    description: "Greeting language (en, es, fr, de, hi)"
    required: false
    default: en

outputs:
  greeted:
    description: Set to "true" once the greeting has been printed
    value: ${{ steps.set-output.outputs.greeted }}

runs:
  using: composite
  steps:
    - name: Print greeting
      shell: bash
      env:
        INPUT_NAME: ${{ inputs.name }}
        INPUT_LANGUAGE: ${{ inputs.language }}
      run: |
        case "$INPUT_LANGUAGE" in
          en) greeting="Hello" ;;
          es) greeting="Hola" ;;
          fr) greeting="Bonjour" ;;
          de) greeting="Hallo" ;;
          hi) greeting="Namaste" ;;
          *)  greeting="Hello"
              echo "Unsupported language '$INPUT_LANGUAGE', falling back to English." ;;
        esac
        echo "$greeting, $INPUT_NAME!"

    - name: Print date and runner OS
      shell: bash
      run: |
        echo "Current date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
        echo "Runner OS: ${{ runner.os }}"

    - name: Set output
      id: set-output
      shell: bash
      run: echo "greeted=true" >> "$GITHUB_OUTPUT"

```

.github/workflows/setup-and-greet.yml
```
name: Greet

on:
  push:
  workflow_dispatch:

jobs:
  greet:
    runs-on: ubuntu-latest
    steps:
      # Required so the local action exists on the runner
      - uses: actions/checkout@v7

      - name: Run setup-and-greet
        id: greet
        uses: ./.github/actions/setup-and-greet
        with:
          name: Octocat
          language: es

      - name: Check output
        run: echo "greeted = ${{ steps.greet.outputs.greeted }}"
```

Reusable Workflow vs Composite Action
Fill this in your notes:

| | Reusable Workflow | Composite Action |
|---|---|---|
| Triggered by | `workflow_call` | `uses:` in a step |
| Can contain jobs? | Yes, multiple jobs | No |
| Can contain multiple steps? | Yes | Yes |
| Lives where? | .github/workflows/*.yml | .github/actions/<action-name>/action.yml |
| Can accept secrets directly? | Yes, through workflow_call.secrets | No, secrets must be passed through inputs or environment variables |
| Best for | Reusing entire CI/CD pipelines | Reusing a group of steps |
