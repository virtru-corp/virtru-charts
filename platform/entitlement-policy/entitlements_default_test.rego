package opentdf.entitlement_tests

import data.opentdf.entitlement
import data.opentdf.entitlementsvc

valid_secondary_entities = ["4f6636ca-c60c-40d1-9f3f-015086303f74", "3f6636ca-c61c-40d1-9f3f-015086303f74"]

get_entitlements_arr = [
	{
		"entity_attributes": [{
			"attribute": "https://example.org/attr/OPA/value/AddedByOPA",
			"displayName": "Added By OPA",
		}],
		"entity_identifier": "4f6636ca-c60c-40d1-9f3f-015086303f74",
	},
	{
		"entity_attributes": [{
			"attribute": "https://example.org/attr/OPA/value/AddedByOPA",
			"displayName": "Added By OPA",
		}],
		"entity_identifier": "3f6636ca-c61c-40d1-9f3f-015086303f74",
	},
	{
		"entity_attributes": [
			{
				"attribute": "https://example.com/attr/Classification/value/S",
				"displayName": "Classification",
			},
			{
				"attribute": "https://example.com/attr/COI/value/PRX",
				"displayName": "COI",
			},
		],
		"entity_identifier": "74cb12cb-4b53-4c0e-beb6-9ddd8333d6d3",
	},
]

test_entitlements_call_success_appends_attr_to_entities_with_empty_attr_sets {
	entitlements := entitlement.generated_entitlements with entitlementsvc.entitlements_fetch_success as get_entitlements_arr

	entitlements[i].entity_identifier == valid_secondary_entities[_]
	entitlements[i].entity_attributes[0] == {
		"attribute": "https://example.org/attr/OPA/value/AddedByOPA",
		"displayName": "Added By OPA",
	}
}

test_merge_attributes_with_core {
	entitlement_objs = [{
		"entity_attributes": [
			{
				"attribute": "https://example.com/attr/Classification/value/S",
				"displayName": "Classification",
			},
			{
				"attribute": "https://example.com/attr/COI/value/PRX",
				"displayName": "COI",
			},
		],
		"entity_identifier": "74cb12cb-4b53-4c0e-beb6-9ddd8333d6d3",
	}]

	entitlements := entitlement.generated_entitlements with entitlementsvc.entitlements_fetch_success as entitlement_objs
		with input as {"entitlement_context": {"email": "unittest@test.com"}, "primary_entity": "74cb12cb-4b53-4c0e-beb6-9ddd8333d6d3"}

	expectedAttributes := array.concat(entitlement_objs[0].entity_attributes, [{
		"attribute": "https://example.org/attr/OPA/value/email",
		"displayName": "unittest@test.com",
	}])

	entitlements[0].entity_attributes == expectedAttributes
}

test_merge_attributes_when_core_attributes_are_missing {
	entitlement_objs = [{
		"entity_attributes": [],
		"entity_identifier": "74cb12cb-4b53-4c0e-beb6-9ddd8333d6d3",
	}]

	entitlements := entitlement.generated_entitlements with entitlementsvc.entitlements_fetch_success as entitlement_objs
		with input as {"entitlement_context": {"email": "unittest@test.com"}, "primary_entity": "74cb12cb-4b53-4c0e-beb6-9ddd8333d6d3"}

	expectedAttributes := [{
		"attribute": "https://example.org/attr/OPA/value/email",
		"displayName": "unittest@test.com",
	}]

	entitlements[0].entity_attributes == expectedAttributes
}
