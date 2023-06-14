package opentdf.entitlementsvc_tests

import data.opentdf.entitlementsvc

primaryEntityValid = "74cb12cb-4b53-4c0e-beb6-9ddd8333d6d3"

secondaryEntitiesValid = ["4f6636ca-c60c-40d1-9f3f-015086303f74"]

httpResSuccess = {
	"body": [
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
		{
			"entity_attributes": [],
			"entity_identifier": "4f6636ca-c60c-40d1-9f3f-015086303f74",
		},
	],
	"status_code": 200,
}

httpResFailure = {
	"body": [
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
		{
			"entity_attributes": [],
			"entity_identifier": "4f6636ca-c60c-40d1-9f3f-015086303f74",
		},
	],
	"status_code": 500,
}

test_entitlements_call_success {
	entitlementsvc.entitlements_fetch_success with entitlementsvc.entitlements_service_fetch as httpResSuccess
		with input.primary_entity as primaryEntityValid
		with input.secondary_entities as secondaryEntitiesValid
}

test_entitlements_call_failure {
	not entitlementsvc.entitlements_fetch_success with entitlementsvc.entitlements_service_fetch as httpResFailure
		with input.primary_entity as primaryEntityValid
		with input.secondary_entities as secondaryEntitiesValid
}
