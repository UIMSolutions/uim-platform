/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.entity_type;

import uim.platform.situation_automation.domain.types;

struct EntityAttribute {
    string name;
    string type;
    string description;
    bool isKey;
}

struct EntityType {
    EntityTypeId id;
    TenantId tenantId;
    string name;
    string description;
    EntityCategory category;
    string sourceSystem;
    EntityAttribute[] attributes;
    string[] relatedTemplateIds;
    string createdBy;
    string modifiedBy;
    long createdAt;
    long modifiedAt;
}
