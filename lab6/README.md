# ☸️ CCS3308 – Virtualization & Containers
## Lab 06: Deep Dive into Kubernetes Fundamentals with Minikube

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Minikube](https://img.shields.io/badge/Minikube-1B2129?style=for-the-badge&logo=minikube&logoColor=white)](https://minikube.sigs.k8s.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

---

## 📌 Context & Objectives

This repository contains the complete implementation, manifests, and technical explanations for **Lab 6: Kubernetes Fundamentals with Minikube**. The lab exercises focus on practical hands-on experience with core Kubernetes primitives, deployment strategies, networking, state persistence, and debugging techniques within a local single-node cluster environment.

Key learning outcomes include:
* **Cluster Architecture Analysis:** Inspecting Control Plane components (`etcd`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`) vs. Worker Node daemons (`kubelet`, `kube-proxy`).
* **Workload Lifecycle:** Understanding Pod ephemerality, automatic IP reassignment, and declarative configuration.
* **Resiliency & Self-Healing:** Observing ReplicaSet control loops automatically reconciling cluster states.
* **Service Discovery & Exposure:** Testing internal dynamic routing via `ClusterIP` and external exposure via `NodePort`.
* **Deployment Strategies:** Implementing zero-downtime rolling updates and automated rollbacks.
* **Stateful Persistence:** Managing databases with `StatefulSet` resources attached to `PersistentVolumeClaim` (PVC).
* **Troubleshooting:** Diagnosing common failures (`ImagePullBackOff`, crashing pods) using core observability commands.

---

## 📂 Repository Structure

```text
.
├── manifests/
│   ├── pod.yaml            # Basic Nginx pod declaration
│   ├── deployment.yaml     # Scalable frontend application deployment
│   ├── service.yaml        # Service definition mapping web traffic
│   ├── postgres.yaml       # PostgreSQL StatefulSet & VolumeClaimTemplate
│   └── broken-pod.yaml     # Faulty manifest for debugging exercises
├── answers.md              # Detailed solutions for Checkpoints Q1–Q9
└── README.md               # Repository documentation
