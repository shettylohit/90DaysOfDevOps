# Day 50: Kubernetes Setup and Architecture

## Task 1: Kubernetes History

Kubernetes was created to solve the problem of managing containers at scale. Docker helps us build and run containers, but it does not provide complete orchestration features like automatic scaling, load balancing, self-healing, and managing containers across multiple machines.

Kubernetes was originally developed by Google and was inspired by Google's internal container management system called Borg.

The name Kubernetes comes from the Greek word meaning "helmsman" or "pilot", someone who steers a ship.

In simple words, Docker runs containers, while Kubernetes manages containers across a cluster of machines.

## Task 2: Kubernetes Architecture

### Architecture Diagram

```text
                 KUBERNETES CLUSTER
                         |
             +-----------------------+
             |     CONTROL PLANE     |
             |                       |
             |  +-----------------+  |
kubectl ---->|  |   API Server    |  |
             |  +-----------------+  |
             |          |            |
             |  +-----------------+  |
             |  |      etcd       |  |
             |  +-----------------+  |
             |                       |
             |  +-----------------+  |
             |  |   Scheduler     |  |
             |  +-----------------+  |
             |                       |
             |  +-----------------+  |
             |  | Controller Mgr  |  |
             |  +-----------------+  |
             +-----------------------+
                         |
                 +-------+-------+
                 |               |
          +-------------+  +-------------+
          | WORKER NODE |  | WORKER NODE |
          |             |  |             |
          |  kubelet    |  |  kubelet    |
          |  kube-proxy |  |  kube-proxy |
          |             |  |             |
          |  +-------+  |  |  +-------+  |
          |  | Pods  |  |  |  | Pods  |  |
          |  +-------+  |  |  +-------+  |
          |             |  |             |
          | Container   |  | Container   |
          | Runtime     |  | Runtime     |
          +-------------+  +-------------+

