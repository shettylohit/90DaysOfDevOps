# Day 60 Capstone: WordPress + MySQL on Kubernetes

## Task 1: Create Namespace (Day 52)

### Command

```bash
kubectl create namespace capstone
kubectl config set-context --current --namespace=capstone
```

### Output

```text
namespace/capstone created
Context modified.
```

### Manifest: `namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: capstone
```

---

## Task 2: Deploy MySQL (Days 54-56)

### 2.1 MySQL Secret

**File:** `mysql-secret.yml`

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: capstone
type: Opaque
stringData:
  MYSQL_ROOT_PASSWORD: "qwerty1234"
  MYSQL_DATABASE: "wordpress"
  MYSQL_USER: "mysqluser"
  MYSQL_PASSWORD: "mysqlpassword"
```

Apply:

```bash
kubectl apply -f mysql-secret.yml
```

Expected output:

```text
secret/mysql-secret created
```

### 2.2 MySQL Headless Service

**File:** `service.yml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: capstone
spec:
  clusterIP: None
  selector:
    app: mysql
  ports:
    - name: mysql
      port: 3306
      targetPort: 3306
      protocol: TCP
```

Apply:

```bash
kubectl apply -f service.yml
```

### 2.3 MySQL StatefulSet

**File:** `mysql-statfulset.yml`

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: capstone
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          envFrom:
            - secretRef:
                name: mysql-secret
          ports:
            - containerPort: 3306
              name: mysql
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: 500m
              memory: 1Gi
          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: mysql-storage
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
```

Apply:

```bash
kubectl apply -f mysql-statfulset.yml
```

### 2.4 PersistentVolume for a cluster without a StorageClass

**File:** `pv.yaml`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/data/mysql
```

Apply:

```bash
kubectl apply -f pv.yaml
```

> **Note:** This `hostPath` configuration is suitable for a single-node lab environment.

### 2.5 Verify MySQL

```bash
kubectl get pods,pvc -n capstone
kubectl get pv
```

Check the database:

```bash
kubectl exec -it mysql-0 -n capstone -- mysql -u mysqluser -pmysqlpassword -e "SHOW DATABASES;"
```

**Result:** The `wordpress` database was successfully verified.

---

## Task 3: Deploy WordPress (Days 52, 54, 57)

### 3.1 Create ConfigMap

**File:** `wordpress-configmap.yml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: wordpress-config-map
  namespace: capstone
data:
  WORDPRESS_DB_HOST: mysql-0.mysql.capstone.svc.cluster.local:3306
  WORDPRESS_DB_NAME: wordpress
```

Apply:

```bash
kubectl apply -f wordpress-configmap.yml
```

### 3.2 WordPress Deployment

**File:** `wordpress-deployment.yml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: capstone
spec:
  replicas: 2
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
        - name: wordpress
          image: wordpress:latest
          ports:
            - containerPort: 80
              name: http
          envFrom:
            - configMapRef:
                name: wordpress-config-map
          env:
            - name: WORDPRESS_DB_USER
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_USER
            - name: WORDPRESS_DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: mysql-secret
                  key: MYSQL_PASSWORD
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          livenessProbe:
            httpGet:
              path: /wp-login.php
              port: 80
            initialDelaySeconds: 60
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /wp-login.php
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 10
```

Apply:

```bash
kubectl apply -f wordpress-deployment.yml
```

### 3.3 Verify WordPress Pods

```bash
kubectl get pods -n capstone
kubectl get deployment wordpress -n capstone
```

---

## Task 4: Expose WordPress (Day 53)

### 4.1 NodePort Service

**File:** `wordpress-service.yml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  namespace: capstone
spec:
  type: NodePort
  selector:
    app: wordpress
  ports:
    - name: http
      port: 80
      targetPort: 80
      nodePort: 30080
      protocol: TCP
```

Apply:

```bash
kubectl apply -f wordpress-service.yml
```

### 4.2 Access WordPress

For Minikube:

```bash
minikube service wordpress -n capstone
```

For Kind or port-forward access:

```bash
kubectl port-forward svc/wordpress 18080:80 -n capstone
```

Open:

```text
http://localhost:18080
```

### 4.3 Verify WordPress

```bash
curl -I http://127.0.0.1:18080/wp-login.php
```

Observed output:

```text
HTTP/1.1 302 Found
Server: Apache/2.4.69 (Debian)
X-Powered-By: PHP/8.3.36
X-Redirect-By: WordPress
Location: http://127.0.0.1:18080/wp-admin/install.php
```

**Result:** WordPress successfully responded and redirected to its installation page.

Complete the WordPress setup wizard and create a sample blog post.

---

## Task 5: Test Self-Healing and Persistence

### 5.1 Test WordPress Self-Healing

Delete one WordPress Pod:

```bash
kubectl delete pod <wordpress-pod-name> -n capstone
```

Watch the Deployment recreate it:

```bash
kubectl get pods -n capstone -w
```

Expected:

- The deleted Pod terminates.
- The Deployment creates a replacement Pod.
- The desired replica count remains 2.

### 5.2 Test MySQL Self-Healing

Delete MySQL Pod:

```bash
kubectl delete pod mysql-0 -n capstone
```

Watch the StatefulSet:

```bash
kubectl get pods -n capstone -w
```

Expected:

- `mysql-0` is recreated.
- The existing PVC is reused.
- MySQL database files remain on persistent storage.

### 5.3 Verify Persistence

```bash
kubectl exec -it mysql-0 -n capstone -- mysql -u mysqluser -pmysqlpassword -e "SHOW DATABASES;"
```

Refresh the WordPress website and verify that the previously created blog post remains available.

**Verification status:** Record the actual result of the Pod deletion and blog post persistence test.

---

## Task 6: Configure HPA (Day 58)

**File:** `wordpress-hpa.yml`

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: wordpress-hpa
  namespace: capstone
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: wordpress
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

Apply:

```bash
kubectl apply -f wordpress-hpa.yml
```

Verify:

```bash
kubectl get hpa -n capstone
kubectl describe hpa wordpress-hpa -n capstone
```

```text
NAME            REFERENCE              TARGETS
wordpress-hpa   Deployment/wordpress   cpu: <unknown>/50%
```

Metrics Server was initially unavailable:

```text
error: Metrics API not available
```

The HPA manifest was created, but CPU-based autoscaling metrics require a working Metrics Server.

### Final resource inspection

```bash
kubectl get all -n capstone
```

---

## Task 7: Compare with Helm (Day 59)

### 7.1 Create a separate namespace

```bash
kubectl create namespace helm-demo
```

### 7.2 Add Bitnami repository

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### 7.3 Install WordPress using Helm

```bash
helm install wp-helm bitnami/wordpress -n helm-demo
```

> If the legacy chart repository is unavailable, check the current chart availability before using its OCI distribution.

### 7.4 Verify Helm deployment

```bash
helm list -n helm-demo
kubectl get all -n helm-demo
kubectl get pvc -n helm-demo
```

### 7.5 Compare Both Approaches

| Feature | Manual YAML | Helm |
|---------|-------------|------|
| Installation | Multiple YAML manifests | Single Helm command |
| Customization | Direct control | Chart values |
| Upgrades | `kubectl apply` | `helm upgrade` |
| Rollback | Manual | `helm rollback` |
| Reusability | Requires templates or duplication | Reusable charts |
| Learning | Detailed Kubernetes knowledge | Packaging and deployment management |

Manual YAML provides more direct control over individual Kubernetes resources.

Helm provides easier installation, configuration, upgrades, and rollback.

### 7.6 Resource Count Comparison

Manual deployment:

```bash
kubectl get all -n capstone
```

Helm deployment:

```bash
kubectl get all -n helm-demo
```

Count displayed resources:

```bash
kubectl get all -n capstone --no-headers | wc -l
kubectl get all -n helm-demo --no-headers | wc -l
```

> **Note:** These commands count resources returned by `kubectl get all`, not every Kubernetes object.

### 7.7 Clean Up Helm

```bash
helm uninstall wp-helm -n helm-demo
kubectl delete namespace helm-demo
```

---

## Task 8: Final Cleanup and Reflection

### 8.1 Final Resource Inspection

```bash
kubectl get all -n capstone
kubectl get pvc,secret,configmap,hpa -n capstone
```

### 8.2 Delete Capstone Namespace

```bash
kubectl delete namespace capstone
```

### 8.3 Reset Default Namespace

```bash
kubectl config set-context --current --namespace=default
```

Verify:

```bash
kubectl config view --minify | grep namespace
kubectl get namespaces
```

> **Note:** The manually created PersistentVolume has a `Retain` reclaim policy and may remain after namespace deletion.

---
