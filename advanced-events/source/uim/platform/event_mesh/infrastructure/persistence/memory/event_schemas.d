/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_schemas;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

class MemoryEventSchemaRepository : TenantRepository!(EventSchema, EventSchemaId), EventSchemaRepository {

    size_t countByFormat(TenantId tenantId, SchemaFormat format) {
        return findByFormat(tenantId, format).length;
    }
    EventSchema[] filterByFormat(EventSchema[] schemas, SchemaFormat format) {
        return schemas.filter!(e => e.format == format).array;
    }
    EventSchema[] findByFormat(TenantId tenantId, SchemaFormat format) {
        return filterByFormat(findByTenant(tenantId), format);
    }
    void removeByFormat(TenantId tenantId, SchemaFormat format) {
        findByFormat(tenantId, format).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, SchemaStatus status) {
        return findByStatus(tenantId, status).length;
    }
    EventSchema[] filterByStatus(EventSchema[] schemas, SchemaStatus status) {
        return schemas.filter!(e => e.status == status).array;
    }
    EventSchema[] findByStatus(TenantId tenantId, SchemaStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    
    void removeByStatus(TenantId tenantId, SchemaStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
