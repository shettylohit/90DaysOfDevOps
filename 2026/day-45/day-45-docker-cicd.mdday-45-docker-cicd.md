### WorkFlow
```
name: Node Application
on: push
defaults:
  run:
    working-directory: node_app

jobs:
  code:
    name: Code Checkout
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the code
        uses: actions/checkout@v7
  docker:
    name: Docker Build and push 
    runs-on: ubuntu-latest
    steps:
       - name: Checkout the code
         uses: actions/checkout@v7
       - name: Docker build  
         uses: docker/build-push-action@v7 
         with:
          context: ./node_app     
          push: false    
          tags: ${{ secrets.DOCKER_USERNAME }}/90days:${{ github.sha}}
       - name: Log in to Docker Hub
         if: github.ref == 'refs/heads/master'
         uses: docker/login-action@v4
         with:
           username: ${{ secrets.DOCKER_USERNAME }}
           password: ${{ secrets.DOCKER_TOKEN }}

       - name: Docker Push
         if: github.ref == 'refs/heads/master'
         uses: docker/build-push-action@v7
         with: 
           context: ./node_app
           push: true   
           tags: ${{ secrets.DOCKER_USERNAME }}/90days:${{ github.sha }}

```

### Commands to download the image and run it 

```
docker pull lohitshetty/90days:442793db4526b1208089a75817f9cd4131704d47

docker run -d -p 3000:3000 lohitshetty/90days:442793db4526b1208089a75817f9cd4131704d47
```
