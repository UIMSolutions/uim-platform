/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.entity_type;

// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct EntityAttribute {
    string name;
    string type;
    string description;
    bool isKey;

    Json toJson() const {
        return Json.emptyObject
            .set("name", name)
            .set("type", type)
            .set("description", description)
            .set("isKey", isKey);
    }
}

struct EntityType {
    mixin TenantEntity!(EntityTypeId);

    string name;
    string description;
    EntityCategory category;
    string sourceSystem;
    EntityAttribute[] attributes;
    string[] relatedTemplateIds;
    
    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("category", category.toString())
            .set("sourceSystem", sourceSystem)
            .set("attributes", attributes.map!(attr => attr.toJson()).array)
            .set("relatedTemplateIds", relatedTemplateIds.array);
    }
}
