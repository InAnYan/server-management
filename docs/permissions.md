# Permissions & Access Control

Operational boundaries, resource pool isolation, and access delegation across the infrastructure stack.

## Resource Pools & Permission Boundaries

To align administrative boundaries with governance tiers, workloads are organized into two distinct Proxmox Resource Pools:

- **Host-Managed Resource Pool (`host-managed`)**:
  - Contains all Core services: Core Coordinator, Core Apps, and Core Databases.
  - Managed exclusively by the Proxmox VE host machine using a dedicated Proxmox API token restricted to the `host-managed` resource pool.
- **Git-Managed Resource Pool (`git-managed`)**:
  - Contains all Dev and Prod workloads: Dev Apps, Dev Databases, Prod Apps, and Prod Databases.
  - Managed declaratively through Git-driven CI/CD automation pipelines using scoped credentials.
