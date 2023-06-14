package opentdf.entitlement

import data.opentdf.entitlementsvc
import future.keywords.in
import input.entitlement_context

custom_attribute_names := attribute_names {
	attribute_names := ["name", "preferredUsername", "email"]
}

generated_entitlements := newEntitlements {
	#Fetch entitlements from rule output
	core_entitlements := entitlementsvc.entitlements_fetch_success

	idp_attributes := construct_idp_attributes(custom_attribute_names)

	entitlements := merge_idp_attributes(core_entitlements, idp_attributes)

	missingAttrs := [st | st = entitlements[_]; count(st.entity_attributes) == 0]
	rest := [st | st = entitlements[_]; count(st.entity_attributes) != 0]

	# NOTE - previously I had thought the only way to do this was with a semi-gnarly object
	# comprehension, but in fact the newly-introduced `in` keyword (imported above, as it's not core yet)
	# makes this pretty simple
	updatedEntities := [entityItem |
		some attr in missingAttrs
		entityItem := {
			"entity_identifier": attr.entity_identifier,
			"entity_attributes": [{
				"attribute": "https://example.org/attr/OPA/value/AddedByOPA",
				"displayName": "Added By OPA",
			}],
		}
	]

	newEntitlements := array.concat(updatedEntities, rest)
}

construct_idp_attributes(attribute_names) = idp_attributes {
	idp_attributes := [attribute |
		some attribute_name in attribute_names
		attribute := construct_idp_attribute(attribute_name)
	]
}

construct_idp_attribute(attribute_name) = idp_attribute {
	# if entitlement_context is provided in input return the idp attribute object
	input.entitlement_context
	input.entitlement_context[attribute_name]
	not is_null(input.entitlement_context[attribute_name])
	idp_attribute := {
		"attribute": concat("", ["https://example.org/attr/OPA/value/", attribute_name]),
		"displayName": input.entitlement_context[attribute_name],
	}
}

merge_idp_attributes(core_entitlements, idp_attributes) = merged_entitlements {
	# merge attributes fetched from backend with idp attributes
	merged_entitlements := [entityItem |
		some entitiy in core_entitlements

		entityItem := {
			"entity_identifier": entitiy.entity_identifier,
			"entity_attributes": array.concat(entitiy.entity_attributes, idp_attributes),
		}
	]
}
