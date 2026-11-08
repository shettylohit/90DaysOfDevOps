
# Day 51 - Kubernetes Pods

## 1. Four Required Fields of a Kubernetes Manifest

A Kubernetes manifest is a YAML file that defines the desired state of a Kubernetes resource.

The four main fields are:

| Field | Description |
|---|---|
| `apiVersion` | Specifies the Kubernetes API version used to create the resource. |
| `kind` | Defines the type of Kubernetes resource, such as Pod, Deployment, or Service. |
| `metadata` | Contains information about the resource, such as its name and labels. |
| `spec` | Defines the desired configuration and behavior of the resource. |

### Example Manifest

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: nginx
```

## 2. Pod Manifests

### A. Nginx Pod

File: `nginx-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

### B. BusyBox Pod

File: `busybox-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
spec:
  containers:
    - name: busybox
      image: busybox:latest
      command: ["sh", "-c", "sleep 3600"]
```

The sleep command keeps the BusyBox container running instead of exiting immediately.

### C. Alpine Pod

File: `alpine-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-pod
  labels:
    app: alpine
spec:
  containers:
    - name: alpine
      image: alpine:latest
      command: ["sh", "-c", "sleep 3600"]
```

The sleep command keeps the Alpine container running.

## 3. Imperative vs Declarative Approach

### Imperative Approach

In the imperative approach, we directly tell Kubernetes what action to perform using commands.

Example:

```bash
kubectl run nginx-pod --image=nginx
```

Characteristics:

- Uses direct commands.
- Creates resources immediately.
- Suitable for quick testing and experimentation.
- Does not automatically maintain configuration in a YAML file.

### Declarative Approach

In the declarative approach, we define the desired state in a YAML manifest and apply it using Kubernetes.

Example:

```bash
kubectl apply -f nginx-pod.yaml
```

Characteristics:

- Uses YAML configuration files.
- Describes the desired state.
- Kubernetes works to maintain the declared configuration.
- Easier to version-control and reuse.
- Suitable for managing infrastructure consistently.

### Key Differences

| Imperative | Declarative |
|---|---|
| Uses direct commands | Uses YAML manifests |
| Specifies what action to perform | Specifies the desired state |
| Example: `kubectl run` | Example: `kubectl apply -f` |
| Good for quick testing | Good for consistent management |

## 4. Create and Verify the Pods

Apply all three manifests:

```bash
kubectl apply -f nginx-pod.yaml
kubectl apply -f busybox-pod.yaml
kubectl apply -f alpine-pod.yaml
```

Check the running Pods:

```bash
kubectl get pods
```

Check additional details:

```bash
kubectl get pods -o wide
```

Expected output (illustrative):

```text
NAME          READY   STATUS    RESTARTS
nginx-pod     1/1     Running   0
busybox-pod   1/1     Running   0
alpine-pod    1/1     Running   0
```


## 5. What Happens When You Delete a Standalone Pod?

When we delete a standalone Pod, Kubernetes does not automatically recreate it.

Example:

```bash
kubectl delete pod nginx-pod
```

Verify deletion:

```bash
kubectl get pods
```

### Explanation

- Kubernetes deletes the specified Pod.
- The Pod is removed from the cluster.
- If it was a standalone Pod, Kubernetes does not create a replacement.
- The application stops running unless another process or controller manages it.

**Important:** A Deployment behaves differently. If a Pod managed by a Deployment is deleted, the Deployment controller creates a replacement Pod to maintain the desired number of replicas.

## 6. Conclusion

Today I learned:

1. The four main fields of a Kubernetes manifest: `apiVersion`, `kind`, `metadata`, and `spec`.
2. How to create Pods using Nginx, BusyBox, and Alpine images.
3. The difference between imperative and declarative resource management.
4. How to apply YAML manifests and verify Pods using `kubectl`.
5. Why deleting a standalone Pod does not automatically recreate it.

**Day 51 Completed - Kubernetes Pods and Pod Manifests.**
