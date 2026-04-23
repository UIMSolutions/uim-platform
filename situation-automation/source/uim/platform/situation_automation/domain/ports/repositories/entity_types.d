/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.entity_types;

// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.entity_type;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface EntityTypeRepository : ITenantRepository!(EntityType, EntityTypeId) {

    size_t countByCategory(TenantId tenantId, EntityCategory category);
    EntityType[] findByCategory(TenantId tenantId, EntityCategory category);
    void removeByCategory(TenantId tenantId, EntityCategory category);

}
