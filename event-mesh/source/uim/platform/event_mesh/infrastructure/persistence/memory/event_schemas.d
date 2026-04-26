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

    size_t countByFormat(SchemaFormat format) {
        return findByFormat(format).length;
    }
    EventSchema[] filterByFormat(EventSchema[] schemas, SchemaFormat format) {
        return schemas.filter!(e => e.format == format).array;
    }
    EventSchema[] findByFormat(SchemaFormat format) {
        return findAll().filter!(e => e.format == format).array;
    }
    void removeByFormat(SchemaFormat format) {
        findByFormat(format).each!(e => remove(e));
    }

    size_t countByStatus(SchemaStatus status) {
        return findByStatus(status).length;
    }
    EventSchema[] filterByStatus(EventSchema[] schemas, SchemaStatus status) {
        return schemas.filter!(e => e.status == status).array;
    }
    EventSchema[] findByStatus(SchemaStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(SchemaStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
