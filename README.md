# ThousandEyes Metrics, Logs, and Traces in OpenTelemetry Weaver

This repository contains ThousandEyes OpenTelemetry Data Model v2 represented as independent Weaver registries.

- `model/thousandeyes/network-app-synthetics-tests/attributes.yaml`
- `model/thousandeyes/network-app-synthetics-tests/metrics.yaml`
- `model/thousandeyes/endpoint-experience-tests/attributes.yaml`
- `model/thousandeyes/endpoint-experience-tests/metrics.yaml`
- `model/thousandeyes/endpoint-experience-local-network/attributes.yaml`
- `model/thousandeyes/endpoint-experience-local-network/metrics.yaml`
- `model/thousandeyes/logs/attributes.yaml`
- `model/thousandeyes/logs/events.yaml`
- `model/thousandeyes/traces/attributes.yaml`
- `model/thousandeyes/traces/spans.yaml`

The registries are organized by these sections to mirror ThousandEyes documentation:

- `Network & App Synthetics Tests`
- `Endpoint Experience - Tests`
- `Endpoint Experience Local Network`
- `Logs (Activity Log)`
- `Traces (Page load, Transaction, API)`

## Automation (validate + docs generation)

This repo includes a `Makefile` with the same generation pattern used in `open-telemetry/semantic-conventions`:

- `registry check` for validation
- `registry generate` for registry pages
- `registry update-markdown` for inline snippet refreshes

### Usage

```bash
# Validate all registries (metrics + logs + traces)
make validate

# Validate, generate docs, and render semconv snippets
make docs

# Update inline semconv snippets (if docs contain <!-- semconv ... --> blocks)
make docs-update-inline
```

### First run behavior

`make` automatically clones OpenTelemetry semantic-conventions templates into `.cache/semantic-conventions` and reuses them for subsequent runs.

### Generated docs structure

For each metrics section, `make docs` generates:

- `docs/<section>/attributes/*` via upstream semantic-conventions templates
- `docs/<section>/metrics/README.md` via local metrics template target
- `docs/<section>/<section>-metrics.md` with upstream-style rendered metric sections via `update-markdown`
- `docs/<section>/README.md` with links to Attributes, Entities, Metrics, and Metric Specs

For logs, `make docs` generates:

- `docs/logs/attributes/*` via upstream semantic-conventions templates
- `docs/logs/events/*` via upstream semantic-conventions templates
- `docs/logs/logs-events.md` with upstream-style rendered event sections via `update-markdown`
- `docs/logs/README.md` with links to Attributes, Entities, and Event Specs

For traces, `make docs` generates:

- `docs/traces/attributes/*` via upstream semantic-conventions templates
- `docs/traces/entities/*` via upstream semantic-conventions templates
- `docs/traces/traces-spans.md` with upstream-style rendered span sections via `update-markdown`
- `docs/traces/README.md` with links to Attributes, Entities, and Span Specs

## Notes

- Each section folder is self-contained and can be validated as its own registry.
- Duplicate metric names are allowed across sections because each section is validated independently.
- Dynamic test/agent tags that become arbitrary OTel attributes are not modeled as fixed keys in this file.
