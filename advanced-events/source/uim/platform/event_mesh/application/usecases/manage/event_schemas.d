/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.event_schemas;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

class ManageEventSchemasUseCase { // TODO: UIMUseCase {
    private EventSchemaRepository repo;

    this(EventSchemaRepository repo) {
        this.repo = repo;
    }

    EventSchema getSchema(TenantId tenantId, EventSchemaId schemaId) {
        return repo.findById(tenantId, schemaId);
    }

    EventSchema[] listSchemas(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventSchema[] listSchemas(TenantId tenantId, SchemaFormat format) {
        return repo.findByFormat(tenantId, format);
    }

    CommandResult createSchema(EventSchemaDTO dto) {
        EventSchema schema;

        schema.id = dto.schemaId;
        schema.tenantId = dto.tenantId;
        schema.name = dto.name;
        schema.description = dto.description;
        schema.version_ = dto.version_;
        schema.schemaContent = dto.schemaContent;
        schema.applicationDomainId = dto.applicationDomainId;
        schema.shared_ = dto.shared_;
        schema.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidEventSchema(schema))
            return CommandResult(false, "", "Invalid event schema data");

        repo.save(schema);
        return CommandResult(true, schema.id.value, "");
    }

    CommandResult updateSchema(EventSchemaDTO dto) {
        auto schema = repo.findById(dto.tenantId, dto.schemaId);
        if (schema.isNull)
            return CommandResult(false, "", "Event schema not found");
            
        if (dto.name.length > 0) schema.name = dto.name;
        if (dto.description.length > 0) schema.description = dto.description;
        if (dto.schemaContent.length > 0) schema.schemaContent = dto.schemaContent;
        if (dto.version_.length > 0) schema.version_ = dto.version_;
        if (!dto.updatedBy.isNull) schema.updatedBy = dto.updatedBy;
        
        repo.update(schema);
        return CommandResult(true, schema.id.value, "");
    }

    CommandResult deleteSchema(TenantId tenantId, EventSchemaId schemaId) {
        auto schema = repo.findById(tenantId, schemaId);
        if (schema.isNull)
            return CommandResult(false, "", "Event schema not found");
            
        repo.remove(schema);
        return CommandResult(true, schema.id.value, "");
    }
}
