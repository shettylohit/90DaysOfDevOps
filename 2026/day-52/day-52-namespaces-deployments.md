
# Day 52 - Kubernetes Namespaces and Deployments

## 1. What Are Kubernetes Namespaces?

A Namespace in Kubernetes is a way to organize and isolate resources within a single Kubernetes cluster.

Namespaces allow us to separate resources based on environments, teams, or projects.

### Default Kubernetes Namespaces

Kubernetes comes with four built-in namespaces:

| Namespace | Purpose |
|---|---|
| `default` | Default namespace where resources are created if no namespace is specified. |
| `kube-system` | Contains Kubernetes system components such as control plane services and networking components. |
| `kube-public` | A namespace readable by all users, including unauthenticated users, by default. |
| `kube-node-lease` | Stores node lease objects used for node heartbeat tracking. |

### Why Do We Use Namespaces?

- Organize resources within a cluster.
- Separate development, staging, and production environments.
- Avoid naming conflicts between resources in different namespaces.
- Apply resource quotas and access controls.
- Manage applications more efficiently.

### Commands to Explore Namespaces

```bash
kubectl get namespaces
```

Check Pods inside the kube-system namespace:

```bash
kubectl get pods -n kube-system
```

Check Pods across all namespaces:

```bash
kubectl get pods -A
```

**Observation:** The number of running Pods in `kube-system` depends on the Kubernetes cluster configuration.

## 2. Create and Use Custom Namespaces

Create two custom namespaces:

```bash
kubectl create namespace dev
kubectl create namespace staging
```

Verify the namespaces:

```bash
kubectl get namespaces
```

### Create a Namespace Using YAML

File: `namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

Apply the manifest:

```bash
kubectl apply -f namespace.yaml
```

Verify:

```bash
kubectl get namespaces
```

### Create Pods in Different Namespaces

Create an Nginx Pod in the development namespace:

```bash
kubectl run nginx-dev --image=nginx:latest -n dev
```

Create an Nginx Pod in the staging namespace:

```bash
kubectl run nginx-staging --image=nginx:latest -n staging
```

List Pods in all namespaces:

```bash
kubectl get pods -A
```

### Difference Between Namespace Commands

```bash
kubectl get pods
```

Displays Pods only from the current namespace, which is `default` unless the current context specifies otherwise.

```bash
kubectl get pods -n dev
```

Displays Pods only from the development namespace.

```bash
kubectl get pods -A
```

Displays Pods from all namespaces.

**Observation:** Pods created in `dev` and `staging` will not appear when running `kubectl get pods` in the default namespace. They will appear when using `kubectl get pods -A`.

## 3. Create Your First Deployment

A Deployment is a Kubernetes resource that manages application Pods.

It ensures that the desired number of replicas are running. If a Pod crashes or gets deleted, the Deployment controller creates a replacement Pod.

### Deployment Manifest

File: `nginx-deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
        ports:
        - containerPort: 80
```

### Explanation of Each Section

| Field | Description |
|---|---|
| `apiVersion: apps/v1` | Specifies the Kubernetes API version for Deployments. |
| `kind: Deployment` | Defines the resource as a Deployment. |
| `metadata` | Contains the Deployment name, namespace, and labels. |
| `spec` | Defines the desired state of the Deployment. |
| `replicas: 3` | Tells Kubernetes to maintain three Pods. |
| `selector` | Identifies the Pods managed by the Deployment. |
| `matchLabels` | Matches Pods with the label `app: nginx`. |
| `template` | Defines the blueprint used to create Pods. |
| `containers` | Specifies the containers that run inside each Pod. |
| `image` | Specifies the container image, Nginx version 1.24. |
| `containerPort: 80` | Documents the container port used by Nginx. |

**Important:** `selector.matchLabels` must match `template.metadata.labels`. Otherwise, the Deployment configuration will be invalid.

### Apply the Deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

Check the Deployment:

```bash
kubectl get deployments -n dev
```

Check the Pods:

```bash
kubectl get pods -n dev
```

Check ReplicaSets:

```bash
kubectl get replicasets -n dev
```

### Understanding Deployment Output

| Column | Meaning |
|---|---|
| `READY` | Number of ready replicas compared to the desired replicas. |
| `UP-TO-DATE` | Number of replicas updated to match the latest Deployment configuration. |
| `AVAILABLE` | Number of replicas available to serve requests. |

Example output:

```text
NAME              READY   UP-TO-DATE   AVAILABLE
nginx-deployment  3/3     3            3
```

This means all three desired Pods are ready and available.

## 4. Self-Healing - Delete a Pod and Watch It Come Back

One of the biggest advantages of Deployments is self-healing.

A standalone Pod does not have a controller to recreate it when deleted.

However, a Deployment continuously monitors the desired number of replicas.

### List Pods

```bash
kubectl get pods -n dev
```

Delete one Pod:

```bash
kubectl delete pod <pod-name> -n dev
```

Check the Pods again:

```bash
kubectl get pods -n dev
```

### What Happens?

1. Kubernetes deletes the selected Pod.
2. The Deployment controller detects that the desired replica count is not maintained.
3. The ReplicaSet controller creates a replacement Pod.
4. The new Pod starts and becomes ready.
5. The Deployment returns to its desired state of three replicas.

**Observation:** The replacement Pod gets a different name from the deleted Pod because Kubernetes creates a new Pod object.

### Standalone Pod vs Deployment-Managed Pod

| Standalone Pod | Deployment-Managed Pod |
|---|---|
| Created directly using a Pod manifest or `kubectl run`. | Created and managed through a Deployment. |
| No Deployment controller manages it. | Managed through a ReplicaSet controlled by the Deployment. |
| Deleting it does not recreate it. | Deleting it triggers creation of a replacement. |
| No automatic replica management. | Maintains the desired replica count. |

## 5. Scale the Deployment

Scaling means increasing or decreasing the number of Pod replicas.

Kubernetes automatically creates or terminates Pods to match the desired replica count.

### Imperative Scaling

Scale up to five replicas:

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n dev
```

Check the Pods:

```bash
kubectl get pods -n dev
```

Scale down to two replicas:

```bash
kubectl scale deployment nginx-deployment --replicas=2 -n dev
```

Verify:

```bash
kubectl get pods -n dev
kubectl get deployments -n dev
```

### Declarative Scaling

We can also scale by modifying the Deployment YAML file.

Change:

```yaml
spec:
  replicas: 3
```

To:

```yaml
spec:
  replicas: 4
```

Apply the updated manifest:

```bash
kubectl apply -f nginx-deployment.yaml
```

Kubernetes adjusts the number of Pods to match the new desired state.

### What Happens When Scaling Down?

When scaling down from five replicas to two:

- Kubernetes identifies three excess Pods.
- Three Pods are terminated.
- Two Pods remain running.
- The Deployment maintains the desired replica count of two.

### Imperative vs Declarative Scaling

| Imperative Scaling | Declarative Scaling |
|---|---|
| Uses `kubectl scale`. | Uses a YAML manifest. |
| Changes the replica count directly. | Changes the desired state in the manifest. |
| Useful for quick scaling operations. | Useful for version-controlled configuration. |

## 6. Rolling Update

A Rolling Update allows us to update an application's container image without terminating all existing Pods at once.

Kubernetes gradually replaces old Pods with new Pods.

### Update the Nginx Image

Update the image from Nginx 1.24 to Nginx 1.25:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
```

Check the rollout status:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

Check the Deployment:

```bash
kubectl get deployments -n dev
```

Check the Pods:

```bash
kubectl get pods -n dev
```

### How Rolling Updates Work

1. A new Deployment revision is created.
2. Kubernetes creates new Pods using the updated image.
3. New Pods become ready.
4. Old Pods are gradually terminated.
5. The Deployment reaches the desired state with the updated image.

This process helps minimize application downtime.

**Note:** Rolling updates do not guarantee zero downtime in every situation. Proper readiness probes, application availability, and rollout settings are important.

### Check Rollout History

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

This displays the previous Deployment revisions.

## 7. Rollback a Deployment

A rollback allows us to return to a previous Deployment revision if an update causes problems.

### Undo the Latest Update

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

Check the rollout status:

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

Verify the image version:

```bash
kubectl describe deployment nginx-deployment -n dev | grep Image
```

The image should return to the previous version, `nginx:1.24`, assuming that was the previous recorded revision.

### Rolling Update vs Rollback

| Rolling Update | Rollback |
|---|---|
| Updates the application to a new version. | Returns the application to a previous revision. |
| Uses `kubectl set image`. | Uses `kubectl rollout undo`. |
| Creates a new Deployment revision. | Restores a previous Deployment configuration. |
| Used when releasing new versions. | Used when an update needs to be reversed. |

## 8. Clean Up Resources

Delete the Deployment:

```bash
kubectl delete deployment nginx-deployment -n dev
```

Delete the standalone Nginx Pod in development:

```bash
kubectl delete pod nginx-dev -n dev
```

Delete the standalone Nginx Pod in staging:

```bash
kubectl delete pod nginx-staging -n staging
```

Delete the custom namespaces:

```bash
kubectl delete namespace dev staging production
```

**Important:** Deleting a namespace also deletes the resources inside that namespace. Be careful when performing this operation in production environments.

Verify the remaining namespaces:

```bash
kubectl get namespaces
```

Check Pods across all namespaces:

```bash
kubectl get pods -A
```

The custom namespaces and their resources should be gone.

## 9. Screenshot - Deployments and Pods Running

Capture a screenshot showing your Deployment and Pods running.

Run the following commands:

```bash
kubectl get deployments -A
```

```bash
kubectl get pods -A
```

Save the screenshot as:

`day-52-deployments.png`

Insert the screenshot below:

![Kubernetes Deployments and Pods running across namespaces](day-52-deployments.png)

**Screenshot should show:**
- The `dev` and `staging` namespaces.
- The Nginx Deployment.
- Multiple running replicas.
- Pods across namespaces.

## 10. Important Kubernetes Commands Learned

| Command | Purpose |
|---|---|
| `kubectl get namespaces` | Lists all namespaces. |
| `kubectl create namespace dev` | Creates a namespace. |
| `kubectl get pods -n dev` | Lists Pods in a namespace. |
| `kubectl get pods -A` | Lists Pods across all namespaces. |
| `kubectl apply -f nginx-deployment.yaml` | Creates or updates a Deployment. |
| `kubectl get deployments -n dev` | Lists Deployments. |
| `kubectl get replicasets -n dev` | Lists ReplicaSets. |
| `kubectl scale deployment nginx-deployment --replicas=5 -n dev` | Scales a Deployment to five replicas. |
| `kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev` | Updates the container image. |
| `kubectl rollout status deployment/nginx-deployment -n dev` | Checks rollout status. |
| `kubectl rollout history deployment/nginx-deployment -n dev` | Shows Deployment revision history. |
| `kubectl rollout undo deployment/nginx-deployment -n dev` | Rolls back the latest Deployment revision. |
| `kubectl delete namespace dev` | Deletes a namespace and its resources. |

