/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.event_schemas;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

interface EventSchemaRepository : ITentRepository!(EventSchema, EventSchemaId) {

    size_t countByFormat(TenantId tenantId, SchemaFormat format);
    EventSchema[] findByFormat(TenantId tenantId, SchemaFormat format);
    void removeByFormat(TenantId tenantId, SchemaFormat format);

    size_t countByStatus(TenantId tenantId, SchemaStatus status);
    EventSchema[] findByStatus(TenantId tenantId, SchemaStatus status);
    void removeByStatus(TenantId tenantId, SchemaStatus status);

}
