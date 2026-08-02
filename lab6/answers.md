# CCS3308 – Virtualization and Containers
## Lab 6: Kubernetes Fundamentals with Minikube — Answers & Explanations

---

## Part 1 — Explore the Cluster Architecture

### Task 1.2 — Kubernetes Components Table

| Observed Pod | Component Type | Kubernetes Component | Purpose |
| :--- | :--- | :--- | :--- |
| `kube-apiserver-minikube` | Control Plane | API Server | Accepts and processes all Kubernetes API requests from users and cluster components. |
| `etcd-minikube` | Control Plane | etcd | Stores the cluster's configuration and current state in a distributed key-value database. |
| `kube-scheduler-minikube` | Control Plane | Scheduler | Assigns newly created Pods to the most suitable worker node. |
| `kube-controller-manager-minikube` | Control Plane | Controller Manager | Runs controllers that ensure the cluster's actual state matches the desired state. |
| `kube-proxy-7b7k4` | Worker Node | kube-proxy | Manages network rules and routes Service traffic to the appropriate Pods. |

#### Component That Did Not Appear as a Pod
During the lab, **`kubelet`** and the **container runtime** (such as Docker or `containerd`) were not listed as Kubernetes Pods. This is because they run as system-level services (daemons) directly on the host node OS rather than being managed inside Kubernetes as Pods. The `kubelet` is responsible for communicating with the control plane and bootstrapping the node to start Pods, so it must already be running before Kubernetes can create and manage any Pods.

---

### Checkpoint Q1 — Difference Between the Control Plane and a Worker Node

The **control plane** is responsible for managing the Kubernetes cluster. It maintains the cluster's overall state, processes API requests, schedules Pods onto suitable nodes, and runs control loops that ensure the cluster operates as expected. Key components include the API Server, Scheduler, Controller Manager, and `etcd`.

A **worker node**, on the other hand, is responsible for executing application workloads. It hosts Pods and uses the `kubelet` to receive instructions from the control plane. The container runtime creates and manages the actual containers inside those Pods, while `kube-proxy` handles network routing and Service traffic management. 

In simple terms: **the control plane makes decisions, whereas the worker nodes execute those decisions.**

---

## Part 2 — Your First Pod

### Checkpoint Q2 — Pod Ephemerality & IP Reassignment

**Observation:** Yes, the Pod IP address changed after deleting and recreating the Pod.

**Explanation:** Kubernetes Pods are designed to be **ephemeral** (temporary and disposable). When a Pod is deleted, its lifetime ends completely, along with its internal network identity and IP allocation. When a new Pod is instantiated from the same manifest, Kubernetes allocates a brand-new IP address from the cluster network range. 

Because Pod IPs are non-static and change frequently during restarts, crashes, or updates, applications should never rely on direct Pod IPs for inter-service communication. Instead, Kubernetes **Services** are used to provide stable, persistent IP addresses and DNS endpoints that dynamically route traffic to running Pods.

---

## Part 3 — From Pod to Deployment: Self-Healing in Action

### Checkpoint Q3 — Control-Loop Self-Healing Process

When the single frontend Pod was deleted, Kubernetes executed its automated **control loop** (reconciliation loop) as follows:

1. **Desired State:** The Deployment configuration specified a desired state of **3 replicas** for the frontend application (`replicas: 3`).
2. **Controller Watches:** The Deployment/ReplicaSet Controller continuously monitors the current cluster state via the API Server.
3. **Actual State:** Upon manual deletion of one Pod, the actual state dropped to **2 running Pods**.
4. **Gap Detected:** The controller detected a mismatch between the desired state (3 Pods) and the actual state (2 Pods).
5. **Reconcile:** The ReplicaSet controller automatically issued an API request to schedule and create a new Pod (`frontend-9d6559d7-5t65q`). Once the container reached the `Running` state, actual state matched desired state again.

---

## Part 4 — Scaling the Deployment

### Checkpoint Q4 — Independent Scaling Architecture

The application architecture isolates components into independent microservice tiers (Frontend, API, Cache, Database). Because each tier is managed by its own independent Kubernetes resource (Deployment or StatefulSet), its lifecycle and resource allocations are entirely decoupled from the others.

When scaling the **Frontend Deployment**, Kubernetes only modifies the number of running `frontend` Pod instances. The underlying **Database StatefulSet** (`postgres`) maintains its own isolated configuration, storage mounts, and replica counts. This independence ensures that high-volume web traffic targeting the frontend can be mitigated by scaling the web tier up, without placing unnecessary management overhead or configuration changes on the persistent database layer.

---

## Part 5 — Exposing the Deployment with a Service

### Checkpoint Q5 — Direct Pod Access vs. Kubernetes Service

* **Direct Access (`kubectl port-forward`):** Establishes a temporary, single-point tunnel directly from the local host machine to a specific target Pod IP/port. If that specific Pod dies or is recreated, the connection drops and requires manual re-forwarding to the new Pod. This pattern is intended strictly for local development and debugging.
* **Service Access (`NodePort` / `ClusterIP`):** Provides an abstraction layer with an immutable Cluster IP and DNS name. A Service uses label selectors (e.g., `app: frontend`) to direct incoming network traffic dynamically across all matching, healthy Pods.

**Why Services Matter:** Because Pods are ephemeral, their individual network endpoints constantly shift. Services provide a single, stable network abstraction that remains unchanged even when underlying Pods fail, scale, or get replaced.

---

## Part 6 — Rolling Updates and Rollbacks

### Checkpoint Q6 — Safety of Rolling Updates vs. Docker Compose

Executing updates and rollbacks safely is significantly more complex using Docker Compose alone because:

1. **Orchestration & Downtime:** Docker Compose stops and recreates containers sequentially or simultaneously on a single host, which frequently leads to temporary service outages during container restart cycles. Kubernetes Deployments perform controlled **rolling updates**, replacing instances incrementally (`maxSurge` / `maxUnavailable`) while ensuring active traffic is continually routed to healthy containers.
2. **State Management & Rollback:** Kubernetes automatically tracks deployment revision histories. If an updated image version fails, running `kubectl rollout undo` immediately reverts the cluster state to the previous working ReplicaSet without manual rebuilds. Docker Compose does not maintain native revision history or automated single-command rollback capabilities.

---

## Part 7 — Deploying the Full Multi-Container Application

### Checkpoint Q7 — Deployment vs. StatefulSet Allocation

| Feature | Deployment (Frontend & API) | StatefulSet (Database - PostgreSQL) |
| :--- | :--- | :--- |
| **State Type** | Stateless | Stateful |
| **Pod Naming** | Random suffixes (e.g., `api-777d9f9547-jlxtg`) | Deterministic, ordinal names (e.g., `postgres-0`) |
| **Storage Model** | Ephemeral, shared, or none | Dedicated persistent volume per pod instance via PVC |
| **Scaling Order** | Parallel startup / shutdown | Strict ordered creation, update, and termination |

* **Deployments** are designed for stateless tiers (Frontend, API) where individual Pod instances are completely interchangeable, hold no local state, and can be created or destroyed rapidly in parallel.
* **StatefulSets** are required for databases (PostgreSQL) where instances require fixed network identities, stable persistent storage attached to specific ordinal indices, and graceful ordered operations to prevent data corruption.

---

## Part 8 — Verifying Persistence

### Checkpoint Q8 — Persistent Volume Survival Analysis

**Answer:** No, the database table data would **not** have survived if PostgreSQL was deployed as a standard Deployment using ephemeral storage.

**Reasoning:** Standard Deployment Pods store file system modifications locally within the container's writable layer. When a Pod instance is terminated, its ephemeral storage layer is completely unmounted and destroyed. Any standard replacement Pod starting up would receive a fresh, empty container file system directory (`/var/lib/postgresql/data`).

In this setup, PostgreSQL was deployed using a **StatefulSet paired with a `volumeClaimTemplate` (PVC)**. When `postgres-0` was deleted, the underlying Persistent Volume provisioned on the host storage system remained intact. As soon as the replacement `postgres-0` Pod was scheduled, Kubernetes re-attached the exact same Persistent Volume back to `/var/lib/postgresql/data`, preserving all SQL schema definitions and stored records (`lab6 test row`).

---

## Part 9 — Observability and Troubleshooting

### Checkpoint Q9 — Broken Pod Status Analysis

* **Observed Status:** `ImagePullBackOff` (initially preceded by `ErrImagePull`).
* **Comparison to Lecture Table:** `ImagePullBackOff` is not listed as one of the primary high-level lifecycle states (which consist of `Pending`, `Running`, `Succeeded`, `Failed`, `Unknown`), but rather represents an extended container waiting state during execution.
* **Meaning:** The status indicates that the kubelet attempted to pull the specified container image (`nginx:definitely-not-a-real-tag`) from the container registry, but the image/tag could not be found or fetched. Kubernetes failed the operation (`ErrImagePull`) and subsequently entered a back-off loop (`ImagePullBackOff`), exponentially delaying consecutive retry attempts to pull the invalid tag to prevent network and registry throttling.
