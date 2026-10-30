```
name: Secret Jobs 
on:
  workflow_dispatch:
jobs:
   job-1:
     name: Job-1
     runs-on: ubuntu-latest
     steps:
       - name: Checkout
         uses: actions/checkout@v7
       - name: Check Secret 
         env: 
             SECRET_MESSAGE : ${{ secrets.MY_SECRET_MESSAGE }}
         run: |
           if [[ -n "$SECRET_MESSAGE" ]]; then
             echo "True"
           else
             echo "False"
           fi
       - name: Print Secret 
         run: echo "${{ secrets.MY_SECRET_MESSAGE }}"  # If you try to print Secret it will only print ****

        
   job-2:
     name: Job-2
     runs-on: ubuntu-latest
     steps:
       - name: Checkout
         uses: actions/checkout@v7
       - name: Print secret 
         env:
             DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
             DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
         run : echo "Docker usrename is $DOCKER_USERNAME and Docker paswsord is $DOCKER_PASSWORD"


  job-3:
    name: Job-3
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7
      - name: Print secret 
        run : cat /etc/os* > text.txt
      - name: Archive test result
        uses: actions/upload-artifact@v7  # Upload the artifact
        with:
            name: Test Result
            path: text.txt


  job-4:
    name: Job-4
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v7
      - name: Download artifact
        uses: actions/download-artifact@v7 # downloaded the artifact
        with:
         name: Test Result
         path: downloaded/
      - name: Read the downloaded File
        run: cat downloaded/text.txt

---------------------------------------------------------

name: Python app

on:
  workflow_dispatch:

jobs:
  code-checkout:
    name: Code checkout and test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v7

      - name: Set up Python
        uses: actions/setup-python@v6
        with:
          python-version: '3.12'
          cache: 'pip'
          cache-dependency-path: requirements.txt

      - name: Install dependencies
        run: python3 -m pip install -r requirements.txt

      - name: Start Flask application
        run: |
          python3 app.py > flask.log 2>&1 &
          echo $! > flask.pid
          sleep 2
          cat flask.log

      - name: Wait for Flask to start
        run: |
          for i in {1..10}; do
            if curl -fsS http://127.0.0.1:5000/health; then
              echo
              echo "Health check passed!"
              exit 0
            fi

            echo "Waiting for Flask... attempt $i"
            sleep 2
          done

          echo "Health check failed!"
          cat flask.log
          exit 1

      - name: Test home page
        run: |
          curl -fsS http://127.0.0.1:5000/ | grep "Hello, World!"

      - name: Stop Flask application
        if: always()
        run: |
          if [ -f flask.pid ]; then
            kill "$(cat flask.pid)" 2>/dev/null || true
          fi
```
