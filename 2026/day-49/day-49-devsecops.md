
name: Main Branch Production Pipeline

on:
  workflow_dispatch:
  # push:
  #   branches:
  #     - main
permissions:
  contents: read
  security-events: write

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

  # Job 3: Scan Docker Image

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

      - name: Upload Trivy Scan Results
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
    needs: security_scan
    runs-on: ubuntu-latest

    environment: production

    steps:
      - name: Deploy Docker Image
        run: |
          echo "Deploying image: ${{ needs.docker_build_push.outputs.image_url }} to production"
