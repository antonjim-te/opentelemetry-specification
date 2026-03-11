SHELL := /bin/bash

WEAVER_IMAGE ?= otel/weaver
PYTHON ?= python3

SEMCONV_REPO_URL ?= https://github.com/open-telemetry/semantic-conventions.git
CACHE_DIR ?= .cache
SEMCONV_REPO_DIR ?= $(CACHE_DIR)/semantic-conventions
SEMCONV_TEMPLATES_ROOT ?= $(SEMCONV_REPO_DIR)/templates
SEMCONV_MARKDOWN_TEMPLATE ?= $(SEMCONV_TEMPLATES_ROOT)/registry/markdown/weaver.yaml
LOCAL_TEMPLATES_ROOT ?= templates
LOCAL_METRICS_TARGET ?= thousandeyes-metrics
LOCAL_METRICS_TEMPLATE ?= $(LOCAL_TEMPLATES_ROOT)/$(LOCAL_METRICS_TARGET)/weaver.yaml
METRICS_LINKER_SCRIPT ?= scripts/link_metrics_in_registry_readme.py
LOGS_LINKER_SCRIPT ?= scripts/link_event_specs_in_registry_readme.py
TRACES_LINKER_SCRIPT ?= scripts/link_span_specs_in_registry_readme.py

NETWORK_APP_REGISTRY ?= model/thousandeyes/network-app-synthetics-tests
ENDPOINT_TESTS_REGISTRY ?= model/thousandeyes/endpoint-experience-tests
ENDPOINT_LOCAL_REGISTRY ?= model/thousandeyes/endpoint-experience-local-network
LOGS_REGISTRY ?= model/thousandeyes/logs
TRACES_REGISTRY ?= model/thousandeyes/traces

NETWORK_APP_DOCS ?= docs/network-app-synthetics-tests
ENDPOINT_TESTS_DOCS ?= docs/endpoint-experience-tests
ENDPOINT_LOCAL_DOCS ?= docs/endpoint-experience-local-network
LOGS_DOCS ?= docs/logs
TRACES_DOCS ?= docs/traces

DOCKER_WEAVER = docker run --rm -v "$(CURDIR):/work" -w /work $(WEAVER_IMAGE)

.PHONY: help templates validate validate-network-app validate-endpoint-tests validate-endpoint-local validate-logs validate-traces docs docs-generate docs-generate-network-app docs-generate-endpoint-tests docs-generate-endpoint-local docs-generate-logs docs-generate-traces docs-generate-metrics docs-generate-metrics-network-app docs-generate-metrics-endpoint-tests docs-generate-metrics-endpoint-local docs-link-metrics docs-link-logs docs-link-traces docs-update-inline docs-update-inline-network-app docs-update-inline-endpoint-tests docs-update-inline-endpoint-local docs-update-inline-logs docs-update-inline-traces clean-cache

help:
	@echo "Automation targets:"
	@echo "  make validate           Validate all registries (metrics + logs + traces)"
	@echo "  make docs-generate      Generate registry index docs and metric index pages"
	@echo "  make docs-link-metrics  Ensure section README links metrics and metric specs pages"
	@echo "  make docs-link-logs     Ensure logs README links event specs page"
	@echo "  make docs-link-traces   Ensure traces README links span specs page"
	@echo "  make docs-update-inline Render semconv snippets in docs pages"
	@echo "  make docs               Validate, generate docs, and render snippets"
	@echo "  make clean-cache        Remove cached upstream templates clone"

templates:
	@mkdir -p "$(CACHE_DIR)"
	@test -d "$(SEMCONV_REPO_DIR)" || git clone --depth 1 "$(SEMCONV_REPO_URL)" "$(SEMCONV_REPO_DIR)"
	@test -f "$(SEMCONV_MARKDOWN_TEMPLATE)"
	@test -f "$(LOCAL_METRICS_TEMPLATE)"

validate: validate-network-app validate-endpoint-tests validate-endpoint-local validate-logs validate-traces

validate-network-app:
	$(DOCKER_WEAVER) registry check -r "$(NETWORK_APP_REGISTRY)" --future

validate-endpoint-tests:
	$(DOCKER_WEAVER) registry check -r "$(ENDPOINT_TESTS_REGISTRY)" --future

validate-endpoint-local:
	$(DOCKER_WEAVER) registry check -r "$(ENDPOINT_LOCAL_REGISTRY)" --future

validate-logs:
	$(DOCKER_WEAVER) registry check -r "$(LOGS_REGISTRY)" --future

validate-traces:
	$(DOCKER_WEAVER) registry check -r "$(TRACES_REGISTRY)" --future

docs: validate docs-generate docs-update-inline

docs-generate: templates docs-generate-network-app docs-generate-endpoint-tests docs-generate-endpoint-local docs-generate-logs docs-generate-traces docs-generate-metrics docs-link-metrics docs-link-logs docs-link-traces

docs-generate-network-app:
	$(DOCKER_WEAVER) registry generate --registry="$(NETWORK_APP_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" markdown "$(NETWORK_APP_DOCS)" --future

docs-generate-endpoint-tests:
	$(DOCKER_WEAVER) registry generate --registry="$(ENDPOINT_TESTS_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" markdown "$(ENDPOINT_TESTS_DOCS)" --future

docs-generate-endpoint-local:
	$(DOCKER_WEAVER) registry generate --registry="$(ENDPOINT_LOCAL_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" markdown "$(ENDPOINT_LOCAL_DOCS)" --future

docs-generate-logs:
	$(DOCKER_WEAVER) registry generate --registry="$(LOGS_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" markdown "$(LOGS_DOCS)" --future

docs-generate-traces:
	$(DOCKER_WEAVER) registry generate --registry="$(TRACES_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" markdown "$(TRACES_DOCS)" --future

docs-generate-metrics: docs-generate-metrics-network-app docs-generate-metrics-endpoint-tests docs-generate-metrics-endpoint-local

docs-generate-metrics-network-app:
	$(DOCKER_WEAVER) registry generate --registry="$(NETWORK_APP_REGISTRY)" --templates="$(LOCAL_TEMPLATES_ROOT)" "$(LOCAL_METRICS_TARGET)" "$(NETWORK_APP_DOCS)" --future

docs-generate-metrics-endpoint-tests:
	$(DOCKER_WEAVER) registry generate --registry="$(ENDPOINT_TESTS_REGISTRY)" --templates="$(LOCAL_TEMPLATES_ROOT)" "$(LOCAL_METRICS_TARGET)" "$(ENDPOINT_TESTS_DOCS)" --future

docs-generate-metrics-endpoint-local:
	$(DOCKER_WEAVER) registry generate --registry="$(ENDPOINT_LOCAL_REGISTRY)" --templates="$(LOCAL_TEMPLATES_ROOT)" "$(LOCAL_METRICS_TARGET)" "$(ENDPOINT_LOCAL_DOCS)" --future

docs-link-metrics:
	$(PYTHON) "$(METRICS_LINKER_SCRIPT)" "$(NETWORK_APP_DOCS)/README.md" "$(ENDPOINT_TESTS_DOCS)/README.md" "$(ENDPOINT_LOCAL_DOCS)/README.md"

docs-link-logs:
	$(PYTHON) "$(LOGS_LINKER_SCRIPT)" "$(LOGS_DOCS)/README.md"

docs-link-traces:
	$(PYTHON) "$(TRACES_LINKER_SCRIPT)" "$(TRACES_DOCS)/README.md"

docs-update-inline: templates docs-update-inline-network-app docs-update-inline-endpoint-tests docs-update-inline-endpoint-local docs-update-inline-logs docs-update-inline-traces

docs-update-inline-network-app:
	$(DOCKER_WEAVER) registry update-markdown --registry="$(NETWORK_APP_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" --target=markdown --future "$(NETWORK_APP_DOCS)"

docs-update-inline-endpoint-tests:
	$(DOCKER_WEAVER) registry update-markdown --registry="$(ENDPOINT_TESTS_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" --target=markdown --future "$(ENDPOINT_TESTS_DOCS)"

docs-update-inline-endpoint-local:
	$(DOCKER_WEAVER) registry update-markdown --registry="$(ENDPOINT_LOCAL_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" --target=markdown --future "$(ENDPOINT_LOCAL_DOCS)"

docs-update-inline-logs:
	$(DOCKER_WEAVER) registry update-markdown --registry="$(LOGS_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" --target=markdown --future "$(LOGS_DOCS)"

docs-update-inline-traces:
	$(DOCKER_WEAVER) registry update-markdown --registry="$(TRACES_REGISTRY)" --templates="$(SEMCONV_TEMPLATES_ROOT)" --target=markdown --future "$(TRACES_DOCS)"

clean-cache:
	rm -rf "$(CACHE_DIR)"
