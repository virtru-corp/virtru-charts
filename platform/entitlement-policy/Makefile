POLICYVERSION?=1.3.0
BUNDLETAG?=ghcr.io/opentdf/entitlement-pdp/entitlements-policybundle

.PHONY: localprep
localprep:
	@echo "Making sure 'opa' CLI is installed"
	@opa version
	@echo "Making sure 'policy' CLI tool is installed"
	@policy version

.PHONY: policybuild
policybuild: localprep test
	@echo "Building '$(BUNDLETAG):$(POLICYVERSION)' OCI policy bundle"
	@policy build -t $(BUNDLETAG):$(POLICYVERSION) .

.PHONY: policypush
policypush: policybuild
	@echo "Pushing '$(BUNDLETAG):$(POLICYVERSION)' OCI policy bundle to registry"
	@policy push $(BUNDLETAG):$(POLICYVERSION)

.PHONY: policypushinsecure
policypushinsecure: policybuild
	@echo "Pushing (without TLS verification, this is insecure and not recommended) '$(BUNDLETAG):$(POLICYVERSION)' OCI policy bundle to registry"
	@policy push --insecure $(BUNDLETAG):$(POLICYVERSION)

.PHONY: test
test: localprep
	@echo "Running all OPA tests"
	@opa test .

#List targets in makefile
.PHONY: list
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
