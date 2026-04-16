/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.repositories.event_schemas;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface EventSchemaRepository {
    bool existsById(EventSchemaId id);
    EventSchema findById(EventSchemaId id);

    EventSchema[] findAll();
    EventSchema[] findByTenant(TenantId tenantId);
    EventSchema[] findByFormat(SchemaFormat format);
    EventSchema[] findByStatus(SchemaStatus status);

    void save(EventSchema schema);
    void update(EventSchema schema);
    void remove(EventSchemaId id);
}
