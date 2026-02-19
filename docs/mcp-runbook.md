# MCP Runbook (Optional)

This repository ships Terraform for repeatable one-click OCI deployment.

If you prefer conversational operations, Oracle first-party MCP server can manage OCI resources and day-2 ops.

## Install OCI MCP server

```bash
uvx oracle.oci-api-mcp-server@latest
```

## Typical MCP operations after deployment

- Resize the OpenClaw instance shape.
- Rotate Vault secret values.
- Inspect Logging/Monitoring and security posture.
- Audit IAM and networking rules.

## Recommended split

- Terraform (this repo): reproducible baseline environment.
- MCP: fast operational changes and guided audits.

Oracle MCP repository:

- https://github.com/oracle/mcp
