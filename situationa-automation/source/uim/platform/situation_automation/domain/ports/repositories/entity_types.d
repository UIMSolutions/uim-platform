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

interface EntityTypeRepository {
    EntityType findById(EntityTypeId id);
    EntityType[] findByTenant(TenantId tenantId);
    EntityType[] findByCategory(TenantId tenantId, EntityCategory category);
    void save(EntityType e);
    void update(EntityType e);
    void remove(EntityTypeId id);
    long countByTenant(TenantId tenantId);
}
