# ThousandEyes Metrics, Logs, and Traces in OpenTelemetry Weaver

This repository contains ThousandEyes OpenTelemetry Data Model v2 and v1 represented as independent Weaver registries.

The model layout is versioned under `model/thousandeyes/v2` and `model/thousandeyes/v1`:

- `model/thousandeyes/v2/metrics/network-app-synthetics-tests/attributes.yaml`
- `model/thousandeyes/v2/metrics/network-app-synthetics-tests/metrics.yaml`
- `model/thousandeyes/v2/metrics/endpoint-experience-tests/attributes.yaml`
- `model/thousandeyes/v2/metrics/endpoint-experience-tests/metrics.yaml`
- `model/thousandeyes/v2/metrics/endpoint-experience-local-network/attributes.yaml`
- `model/thousandeyes/v2/metrics/endpoint-experience-local-network/metrics.yaml`
- `model/thousandeyes/v2/logs/attributes.yaml`
- `model/thousandeyes/v2/logs/events.yaml`
- `model/thousandeyes/v2/traces/attributes.yaml`
- `model/thousandeyes/v2/traces/spans.yaml`
- `model/thousandeyes/v1/metrics/network-app-synthetics-tests/attributes.yaml`
- `model/thousandeyes/v1/metrics/network-app-synthetics-tests/metrics.yaml`
- `model/thousandeyes/v1/metrics/endpoint-experience-tests/attributes.yaml`
- `model/thousandeyes/v1/metrics/endpoint-experience-tests/metrics.yaml`

The registries are organized by these sections to mirror ThousandEyes documentation:

- `Metrics`
  - `Network & App Synthetics Tests`
  - `Endpoint Experience - Tests`
  - `Endpoint Experience Local Network`
- `Logs`
  - `Activity Log`
- `Traces`
  - `Network & App Synthetics Tests`

## Automation (validate + docs generation)

This repo includes a `Makefile` with the same generation pattern used in `open-telemetry/semantic-conventions`:

- `registry check` for validation
- `registry generate` for registry pages
- `registry update-markdown` for inline snippet refreshes

### Usage

```bash
# Validate all registries (v2 + v1, metrics + logs + traces)
make validate

# Validate, generate docs, and render semconv snippets
make docs

# Update inline semconv snippets (if docs contain <!-- semconv ... --> blocks)
make docs-update-inline
```

### First run behavior

`make` automatically clones OpenTelemetry semantic-conventions templates into `.cache/semantic-conventions` and reuses them for subsequent runs.

### Generated docs structure

For each Data Model v2 metrics section, `make docs` generates:

- `docs/v2/<section>/attributes/*` via upstream semantic-conventions templates
- `docs/v2/<section>/metrics/README.md` via local metrics template target
- `docs/v2/<section>/<section>-metrics.md` with upstream-style rendered metric sections via `update-markdown`
- `docs/v2/<section>/README.md` with links to Attributes, Entities, Metrics, and Metric Specs

For each Data Model v1 metrics section, `make docs` generates:

- `docs/v1/<section>/attributes/*` via upstream semantic-conventions templates
- `docs/v1/<section>/metrics/README.md` via local metrics template target
- `docs/v1/<section>/<section>-metrics.md` with upstream-style rendered metric sections via `update-markdown`
- `docs/v1/<section>/README.md` with links to Attributes, Entities, Metrics, and Metric Specs

For logs, `make docs` generates:

- `docs/v2/logs/attributes/*` via upstream semantic-conventions templates
- `docs/v2/logs/events/*` via upstream semantic-conventions templates
- `docs/v2/logs/logs-events.md` with upstream-style rendered event sections via `update-markdown`
- `docs/v2/logs/README.md` with links to Attributes, Entities, and Event Specs

For traces, `make docs` generates:

- `docs/v2/traces/attributes/*` via upstream semantic-conventions templates
- `docs/v2/traces/entities/*` via upstream semantic-conventions templates
- `docs/v2/traces/traces-spans.md` with upstream-style rendered span sections via `update-markdown`
- `docs/v2/traces/README.md` with links to Attributes, Entities, and Span Specs

## Notes

- Each section folder is self-contained and can be validated as its own registry.
- Duplicate metric names are allowed across sections because each section is validated independently.
- Dynamic test/agent tags that become arbitrary OTel attributes are not modeled as fixed keys in this file.
