/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.infrastructure.persistence.memory.event_schemas;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class MemoryEventSchemaRepository : EventSchemaRepository {
    private EventSchema[] store;

    bool existsById(EventSchemaId id) {
        return store.any!(e => e.id == id);
    }

    EventSchema findById(EventSchemaId id) {
        foreach (e; findAll)
            if (e.id == id) return e;
        return EventSchema.init;
    }

    EventSchema[] findAll() { return store; }

    EventSchema[] findByTenant(TenantId tenantId) {
        return findAll().filter!(e => e.tenantId == tenantId).array;
    }

    EventSchema[] findByFormat(SchemaFormat format) {
        return findAll().filter!(e => e.format == format).array;
    }

    EventSchema[] findByStatus(SchemaStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }

    void save(EventSchema schema) { store ~= schema; }

    void update(EventSchema schema) {
        foreach (ref e; store)
            if (e.id == schema.id) { e = schema; return; }
    }

    void remove(EventSchemaId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}
