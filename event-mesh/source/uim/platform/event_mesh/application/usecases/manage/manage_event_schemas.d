/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.manage_event_schemas;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageEventSchemasUseCase { // TODO: UIMUseCase {
    private EventSchemaRepository repo;

    this(EventSchemaRepository repo) {
        this.repo = repo;
    }

    EventSchema getById(EventSchemaId id) {
        return repo.findById(id);
    }

    EventSchema[] list() {
        return repo.findAll();
    }

    EventSchema[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventSchema[] listByFormat(SchemaFormat format) {
        return repo.findByFormat(format);
    }

    CommandResult create(EventSchemaDTO dto) {
        EventSchema s;
        s.id = EventSchemaId(dto.id);
        s.tenantId = dto.tenantId;
        s.name = dto.name;
        s.description = dto.description;
        s.version_ = dto.version_;
        s.schemaContent = dto.schemaContent;
        s.applicationDomainId = dto.applicationDomainId;
        s.shared_ = dto.shared_;
        s.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidEventSchema(s))
            return CommandResult(false, "", "Invalid event schema data");
        repo.save(s);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(EventSchemaDTO dto) {
        auto existing = repo.findById(EventSchemaId(dto.id));
        if (existing.isNull)
            return CommandResult(false, "", "Event schema not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.schemaContent.length > 0) existing.schemaContent = dto.schemaContent;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(EventSchemaId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Event schema not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
