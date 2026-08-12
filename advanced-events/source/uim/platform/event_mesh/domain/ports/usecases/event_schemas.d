/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.event_schemas;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageEventSchemasUseCase { 

    EventSchema getSchema(TenantId tenantId, EventSchemaId schemaId);
    EventSchema[] listSchemas(TenantId tenantId);
    EventSchema[] listSchemas(TenantId tenantId, SchemaFormat format);
    CommandResult createSchema(EventSchemaDTO dto);
    CommandResult updateSchema(EventSchemaDTO dto);
    CommandResult deleteSchema(TenantId tenantId, EventSchemaId schemaId);
}

