# Manage Caddy Routing via Modular Configuration Files

- Status: accepted
- Date: 2026-11-10

## Context and Problem Statement

The platform uses Caddy as its central Layer 7 ingress reverse proxy on `core-coord-caddy` to route incoming traffic across internal virtual machines and terminate TLS certificates.

As new application workloads are deployed through developer Git repositories and Atlantis GitOps, routes must be provisioned and updated dynamically. We need to decide how Infrastructure as Code (IaC) tools—specifically Ansible for core platform services and developer deployment pipelines for application workloads—should interact with Caddy to configure reverse proxy routes.

Caddy supports configuration through two distinct mechanisms:

1. Static Caddyfile definitions loaded at startup and reloaded on demand.
2. An embedded HTTP REST Administration API (`localhost:2019`) that modifies active memory and periodically flushes state to an `autosave.json` file.

We must establish a single, robust, and consistent configuration strategy that guarantees persistence across reboots, avoids configuration drift, and unifies both core infrastructure and developer GitOps workflows.

## Decision Drivers

- **Operational Simplicity**: Minimize moving parts and avoid fragile synchronization mechanisms.
- **Unified Workflow**: A single routing pattern that works seamlessly for core infrastructure (Ansible) and Git-managed developer applications (GitOps / CI/CD).
- **Reboot Persistence & Determinism**: Absolute assurance that routes survive container restarts, host reboots, and rolling service updates without state loss.
- **IaC Tool Compatibility**: Seamless fit with our automation layers without introducing split-brain state or conflicting sources of truth.
- **Auditability**: Plaintext, inspectable configuration on disk for troubleshooting and git history.

## Considered Options

- **Option 1: Modular Configuration Files (`conf.d/*.Caddyfile`) with Graceful Reload**
- **Option 2: Admin REST API and `autosave.json` (`caddy run --resume`)**
- **Option 3: Mixed Strategy (Configuration Files for Core Services, Admin REST API for App Workloads)**

## Decision Outcome

Chosen option: "Option 1: Modular Configuration Files (`conf.d/*.Caddyfile`) with Graceful Reload", because it provides a unified, deterministic, and 100% persistent mechanism that serves both core platform services and application workloads identically.

While the OpenTofu community provider for Caddy interacts directly with the Admin REST API (making Option 2 superficially appealing), OpenTofu is not used to manage Caddy or core services during base server bootstrap—Ansible manages base server configuration. Adopting Option 1 allows Ansible to manage routes for both core services and application deployments consistently.

Furthermore, Option 3 (a mixed approach) is fundamentally broken in Caddy: when `--resume` is enabled, Caddy ignores updates to `Caddyfile` and `conf.d/` if an `autosave.json` exists; conversely, without `--resume`, Caddy wipes all runtime API changes upon container restart.

### Positive Consequences

- **100% Reboot Persistence**: Every route is backed by a physical file in `/opt/caddy/conf.d/` mounted into the container at `/etc/caddy/conf.d/`. Reboots and container restarts never lose routes.
- **Zero Downtime Reloads**: Reloading Caddy via `caddy reload --config /etc/caddy/Caddyfile` (or `POST /load`) checks syntax before applying; invalid route configurations are rejected without dropping active connections.
- **Uniform Automation**: Both core coordinators (`ansible/roles/caddy/`) and developer deployments (`apps/<app>/ansible/`) use standard Ansible file and template modules.
- **No Split-Brain**: A single source of truth exists on disk. Operators can immediately see all active routes via `ls /opt/caddy/conf.d/`.

### Negative Consequences

- Deploying a route requires write access to `/opt/caddy/conf.d/` on `core-coord-caddy` over SSH, rather than sending an unauthenticated HTTP POST from within the SDN. (This is also an operational security advantage, ensuring route changes are authenticated).

## Pros and Cons of the Options

### Option 1: Modular Configuration Files (`conf.d/*.Caddyfile`) with Graceful Reload

Store the base configuration in `/etc/caddy/Caddyfile` with `import /etc/caddy/conf.d/*`. Each service or application maintains an independent `.Caddyfile` snippet dropped by Ansible or CI over SSH, followed by an atomic reload.

- Good, because 100% persistent across container recreations and host reboots.
- Good, because unified across all infrastructure tiers (core, dev, prod).
- Good, because syntax validation occurs before activation, preventing broken routing states.
- Good, because human-readable, auditable, and easily debugged directly from the filesystem.
- Bad, because requires SSH access to `core-coord-caddy` to deploy snippets.

### Option 2: Admin REST API and `autosave.json` (`caddy run --resume`)

Manage Caddy entirely through its HTTP REST API (`http://10.10.1.10:2019/config/...`), running Caddy with `--resume` to persist changes into `autosave.json`.

- Good, because enables native OpenTofu Caddy provider resources without SSH credentials.
- Bad, because core platform services are bootstrapped with Ansible, not OpenTofu, forcing a divergent setup.
- Bad, because `autosave.json` is a machine-generated JSON blob that is difficult to inspect, diff, or audit.
- Bad, because if `autosave.json` becomes corrupted or invalid, Caddy fails to start entirely on reboot.

### Option 3: Mixed Strategy (Files for Core, REST API for Apps)

Use `Caddyfile` for core infrastructure, while allowing developer CI pipelines or OpenTofu to inject application routes into the running Caddy instance via `POST /config/...`.

- Bad, because technically incompatible with Caddy's architecture:
  - Without `--resume`: container restarts or service reloads wipe all API-injected routes.
  - With `--resume`: Caddy ignores all static `Caddyfile` edits as long as `autosave.json` exists on disk.
- Bad, because creates split-brain state where operators cannot know which routes are active from looking at the repository or filesystem.
