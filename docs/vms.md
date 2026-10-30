# Virtual Machines Registry

Inventory and functional catalog of all virtual machines provisioned across infrastructure environments.

Workloads marked as stateful (**Yes**) store persistent application data, configuration, or database files on disk and require scheduled backups. Stateless workloads (**No**) do not retain unique local state and can be recreated on demand via OpenTofu and Ansible.

## Core

### Core Coordinators (coord)

| Machine ID | Machine Name | IP Address | Service | Stateful | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `1000` | `core-coord-caddy` | `10.10.1.10` | Caddy | Yes | Ingress reverse proxy, automated TLS termination, and L7 routing |

### Core Applications (app)

| Machine ID | Machine Name | IP Address | Service | Stateful | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `1500` | `core-app-testvm` | `10.11.0.10` | Test VM | No | Baseline test virtual machine in core applications tier |

### Core Databases & Storage (data)

*No workloads currently provisioned.*

## Dev

### Dev Applications (app)

*No workloads currently provisioned.*

### Dev Databases & Storage (data)

*No workloads currently provisioned.*

## Prod

### Prod Applications (app)

*No workloads currently provisioned.*

### Prod Databases & Storage (data)

*No workloads currently provisioned.*
