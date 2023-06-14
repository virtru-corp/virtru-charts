package opentdf.entitlementsvc

import data.opentdf.entitlements_service
import input.primary_entity
import input.secondary_entities

# NOTE this is a separate rule because ATM `http.send` calls cannot be mocked
# in rego tests the way everything else can - so we mock this rule entirely
entitlements_service_fetch = response {
	response := http.send({
		"method": "POST",
		"url": entitlements_service.url,
		"body": {
			"primary_entity_id": primary_entity,
			"secondary_entity_ids": secondary_entities,
		},
	})
}

# This rule is what package consumers should check -
# it checks that the response meets criteria for a valid entitlement,
# and will return [] if those criteria are not met.
entitlements_fetch_success = entitlements {
	response := entitlements_service_fetch

	# Following must be TRUE or rule will eval to empty array
	response.body != null
	response.status_code == 200

	# CHECK - entitlements prop on body?
	entitlements := response.body

	# CHECK - Is one of the entitlement set identifiers == primary entity?
	primary_entity == entitlements[_].entity_identifier

	# CHECK - For every secondary entity ID in input, does that secondary entity ID exist in the obtained entitlement set?
	check_secondaries
}

# Rules with the same name are OR'd - so one of these rules should always be TRUE
# either
# - there are NO secondary entities in input that we're fetching attributes for OR
# - there ARE secondary entities in input, and for each secondary entity, entitlements returned us a result set.
check_secondaries {
	count(secondary_entities) == 0
}

check_secondaries {
	count(secondary_entities) != 0
	secondary_entities[_] == entitlements_service_fetch.body[_].entity_identifier
}
