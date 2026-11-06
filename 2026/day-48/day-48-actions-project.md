py_flask_app.yml
```
name: Flask App

on:
  push:
    inputs:
      flask_version:
        description: 'Version of Flask'
        type: number
        required: true
        default: 3.1.2

      run_test:
        description: 'Run test'
        type: string
        required: true
defaults:
  run:
    working-directory: python_flask

jobs:
  code:
    name: Code Checkout
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the code
        uses: actions/checkout@v7
      - name: Set up Python
        uses: actions/setup-python@v6
        with:
          python-version: "3.12"
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest
      - name: Run pytest
        run: pytest -v
```
reusable-build-test.yml
```

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
        value: ${{ jobs.build.outputs.test_result }}

jobs:
  build:
    name: Build and Test Flask App
    runs-on: ubuntu-latest

    outputs:
      test_result: ${{ steps.test_status.outputs.result }}

    defaults:
      run:
        working-directory: python_flask

    steps:
      - name: Checkout Code
        uses: actions/checkout@v7
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

      - name: Run Tests
        id: tests
        if: ${{ inputs.run_tests }}
        run: pytest -v

      - name: Set Test Result
        id: test_status
        if: always()
        run: |
          if [[ "${{ steps.tests.outcome }}" == "success" ]]; then
            echo "result=passed" >> "$GITHUB_OUTPUT"
          elif [[ "${{ steps.tests.outcome }}" == "skipped" ]]; then
            echo "result=skipped" >> "$GITHUB_OUTPUT"
          else
            echo "result=failed" >> "$GITHUB_OUTPUT"
          fi

```

reusable-docker.yml

```

name: Reusable Workflow for Flask Application - Docker Build & Push

on:
  workflow_call:
    inputs:
      image_name:
        description: 'Docker Image Name'
        type: string
        required: true
        default: "python_flask_app"

      tag:
        description: 'Docker Image Tag'
        type: string
        required: true
        default: "v1"

    secrets:
      docker_username:
        description: 'Docker Hub Username'
        required: true

      docker_token:
        description: 'Docker Hub Access Token'
        required: true

    outputs:
      image_url:
        description: 'Full Docker Image URL'
        value: ${{ jobs.build.outputs.image_url }}

jobs:
  build:
    name: Build and Push Image
    runs-on: ubuntu-latest

    outputs:
      image_url: ${{ steps.image.outputs.image_url }}

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v5
        with:
          username: ${{ secrets.docker_username }}
          password: ${{ secrets.docker_token }}

      - name: Build and Push Docker Image
        uses: docker/build-push-action@v6
        with:
          context: .
          file: ./python_flask/Dockerfile
          push: true
          tags: ${{ secrets.docker_username }}/90days/${{ inputs.image_name }}:${{ inputs.tag }}

      - name: Set Image URL
        id: image
        run: |
          echo "image_url=${{ secrets.docker_username }}/90days/${{ inputs.image_name }}:${{ inputs.tag }}" >> "$GITHUB_OUTPUT"

```

pr-pipeline.yml

```

name: Pull Request Pipeline

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize

jobs:
  build_test:
    name: Build and Test
    uses: ./.github/workflows/reusable-build-test.yml
    with:
      python_version: '3.12'
      run_tests: true

  pr-comment:
    name: PR Summary
    runs-on: ubuntu-latest
    needs: build_test

    steps:
      - name: Print PR Summary
        run: |
          echo "PR checks passed for branch: ${{ github.head_ref }}"

```

main-pipeline.yml

```

name: Main Branch Production Pipeline

on:
  push:
    branches:
      - main

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

  # Job 3: Deploy to Production
  deploy:
    name: Deploy to Production
    needs: docker_build_push
    runs-on: ubuntu-latest

    environment: production

    steps:
      - name: Deploy Docker Image
        run: |
          echo "Deploying image: ${{ needs.docker_build_push.outputs.image_url }} to production"

```

health-check.yml

```

name: Scheduled Docker Health Check

on:
  schedule:
    - cron: '0 */12 * * *'

  workflow_dispatch:

jobs:
  health_check:
    name: Check Flask Application Health
    runs-on: ubuntu-latest

    steps:
      - name: Pull Latest Docker Image
        run: |
          docker pull ${{ secrets.docker_username }}/90days/flask-capstone:latest

      - name: Run Docker Container
        run: |
          docker run -d \
            --name flask-health-check \
            -p 5000:5000 \
            ${{ secrets.docker_username }}/90days/flask-capstone:latest

      - name: Wait for Application Startup
        run: sleep 5

      - name: Check Health Endpoint
        id: health
        run: |
          if curl --fail --silent http://localhost:5000/health; then
            echo "Health check PASSED"
            echo "status=PASSED" >> "$GITHUB_OUTPUT"
          else
            echo "Health check FAILED"
            echo "status=FAILED" >> "$GITHUB_OUTPUT"
            exit 1
          fi

      - name: Create Health Check Summary
        if: always()
        run: |
          echo "## Health Check Report" >> $GITHUB_STEP_SUMMARY
          echo "- Image: ${{ secrets.docker_username }}/90days/flask-capstone:latest" >> $GITHUB_STEP_SUMMARY
          echo "- Status: ${{ steps.health.outputs.status || 'FAILED' }}" >> $GITHUB_STEP_SUMMARY
          echo "- Time: $(date)" >> $GITHUB_STEP_SUMMARY

      - name: Stop and Remove Container
        if: always()
        run: |
          docker stop flask-health-check || true
          docker rm flask-health-check || true

```

