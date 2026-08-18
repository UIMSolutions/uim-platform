/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.event_schemas;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageEventSchemasUseCase {
    protected IEventSchemaRepository repo;

    this(IEventSchemaRepository repo) {
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

    UsecaseResult createSchema(EventSchemaDTO dto) {
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
            return UsecaseResult(false, "", "Invalid event schema data");

        repo.save(schema);
        return UsecaseResult(true, schema.id.value, "");
    }

    UsecaseResult updateSchema(EventSchemaDTO dto) {
        auto schema = repo.findById(dto.tenantId, dto.schemaId);
        if (schema.isNull)
            return UsecaseResult(false, "", "Event schema not found");
            
        if (dto.name.length > 0) schema.name = dto.name;
        if (dto.description.length > 0) schema.description = dto.description;
        if (dto.schemaContent.length > 0) schema.schemaContent = dto.schemaContent;
        if (dto.version_.length > 0) schema.version_ = dto.version_;
        if (!dto.updatedBy.isNull) schema.updatedBy = dto.updatedBy;
        
        repo.update(schema);
        return UsecaseResult(true, schema.id.value, "");
    }

    UsecaseResult deleteSchema(TenantId tenantId, EventSchemaId schemaId) {
        auto schema = repo.findById(tenantId, schemaId);
        if (schema.isNull)
            return UsecaseResult(false, "", "Event schema not found");
            
        repo.remove(schema);
        return UsecaseResult(true, schema.id.value, "");
    }
}

///
unittest {
//    auto repo = new EventSchemaRepository();
//    auto usecase = new ManageEventSchemasUseCase(repo);
//    auto tenantId = TenantId("test-tenant");
//
//    // Test create
//    EventSchemaDTO createDto;
//    createDto.tenantId = tenantId;
//    createDto.eventSchemaId = EventSchemaId("eventSchema-1");
//    createDto.name = "Test EventSchema";
//    auto createResult = usecase.createSchema(createDto);
//    assert(createResult.success, createResult.message);
//
//    // Test list
//    auto items = usecase.listSchemas(tenantId);
//    assert(items.length == 1);
//
//    // Test get
//    auto item = usecase.getSchema(tenantId, EventSchemaId("eventSchema-1"));
//    assert(!item.isNull);
//
//    // Test update
//    EventSchemaDTO updateDto;
//    updateDto.tenantId = tenantId;
//    updateDto.eventSchemaId = EventSchemaId("eventSchema-1");
//    updateDto.name = "Updated EventSchema";
//    auto updateResult = usecase.updateSchema(updateDto);
//    assert(updateResult.success, updateResult.message);
//
//    // Test delete
//    auto deleteResult = usecase.deleteSchema(tenantId, EventSchemaId("eventSchema-1"));
//    assert(deleteResult.success, deleteResult.message);
//    assert(usecase.listSchemas(tenantId).length == 0);

}
