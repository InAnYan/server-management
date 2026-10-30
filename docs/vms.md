# Virtual Machines Registry

Inventory and functional catalog of all virtual machines provisioned across infrastructure environments.

## Core

### Core Coordinators (coord)

- **Machine Name**: `core-coord-caddy`
  - **Machine ID**: `1000`
  - **IP Address**: `10.10.1.10`
  - **Service**: Caddy
  - **Purpose**: Ingress reverse proxy, automatic TLS termination, and L7 routing for all external web traffic.

### Core Applications (app)

- **Machine Name**: `core-app-testvm`
  - **Machine ID**: `1500`
  - **IP Address**: `10.11.0.10`
  - **Service**: Test Application VM
  - **Purpose**: Baseline test virtual machine in the core applications tier.

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
