# Choose Caddy as Ingress Reverse Proxy

- Status: accepted
- Date: 2026-11-02

## Context and Problem Statement

The infrastructure operates on a host with a single public IPv4 address. Multiple internal web services and dashboards (Technitium DNS, Gatus, Gitea) reside on isolated internal Software-Defined Networking (SDN) subnets without direct public routing.

We require an ingress reverse proxy and Layer 7 router to terminate TLS certificates automatically, route traffic based on Host headers (SNI / domain names), and forward requests to internal VM backends.

## Decision Drivers

- **Automated TLS Lifecycle**: Built-in, automated certificate acquisition and renewal (ACME / Let's Encrypt / ZeroSSL) without requiring external scripts, cron jobs, or Certbot.
- **Modular Configuration**: Clean support for splitting site definitions into independent files (`conf.d/*.Caddyfile`) templated via Ansible.
- **Resource Footprint**: Minimal memory and CPU consumption suitable for a single coordinator VM (`core-coord-caddy`, 1 GB RAM).
- **Graceful Dynamic Reload**: Ability to reload routing configurations on the fly without dropping active connections.

## Considered Options

- Caddy
- Nginx
- Traefik
- HAProxy

## Decision Outcome

Chosen option: "Caddy", because it provides native, zero-configuration TLS management out of the box, uses an intuitive and concise Caddyfile syntax with native modular `import` support, and runs efficiently as a single binary inside a lightweight container.

### Positive Consequences

- Automatic certificate provisioning and renewal with zero operational maintenance or Certbot dependencies.
- Modular route configuration in `/opt/caddy/conf.d/` allows Ansible to add, modify, or remove service routes independently.
- Fast configuration verification and zero-downtime reloads via `caddy reload`.
- Low memory footprint (~30 MB RSS in container runtime).

### Negative Consequences

- Advanced or non-standard routing features may require third-party Caddy modules compiled via `xcaddy`.
- Different configuration syntax compared to traditional Nginx directives.

## Pros and Cons of the Options

### Caddy

- Good, because automated TLS certificate issuance and renewal is built-in by default.
- Good, because concise Caddyfile syntax drastically reduces configuration boilerplate.
- Good, because modular file imports (`import /etc/caddy/conf.d/*`) make Ansible templating straightforward.
- Bad, because custom Caddy plugins require custom builds via `xcaddy`.

### Nginx

- Good, because industry standard with extensive documentation and broad community familiarity.
- Bad, because automated TLS requires external tooling (Certbot, cron jobs, or lua scripts) and external renewal hooks.
- Bad, because configuration syntax is more verbose for basic reverse proxy directives.

### Traefik

- Good, because native dynamic discovery support for container engines and orchestrators.
- Bad, because configuration relies heavily on labels or complex dynamic TOML/YAML files with higher memory overhead.
- Bad, because unnecessarily complex for static VM-based internal backends with deterministic IP addresses.

### HAProxy

- Good, because exceptional performance and battle-tested Layer 4/Layer 7 proxy capabilities.
- Bad, because automated ACME TLS certificate management requires external helper daemons or Lua scripting.
- Bad, because configuration is more complex and less suited for rapid declarative site templating.
