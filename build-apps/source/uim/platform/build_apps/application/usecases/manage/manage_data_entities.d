/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.manage_data_entities;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageDataEntitiesUseCase : UIMUseCase {
    private DataEntityRepository repo;

    this(DataEntityRepository repo) {
        this.repo = repo;
    }

    DataEntity getById(DataEntityId id) {
        return repo.findById(id);
    }

    DataEntity[] list() {
        return repo.findAll();
    }

    DataEntity[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataEntity[] listByApplication(ApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult create(DataEntityDTO dto) {
        DataEntity e;
        e.id = DataEntityId(dto.id);
        e.tenantId = dto.tenantId;
        e.applicationId = ApplicationId(dto.applicationId);
        e.name = dto.name;
        e.description = dto.description;
        e.fields = dto.fields;
        e.primaryKey = dto.primaryKey;
        e.indexes = dto.indexes;
        e.validationRules = dto.validationRules;
        e.defaultValues = dto.defaultValues;
        e.relations = dto.relations;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidDataEntity(e))
            return CommandResult(false, "", "Invalid data entity");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(DataEntityDTO dto) {
        if (!repo.existsById(DataEntityId(dto.id)))
            return CommandResult(false, "", "Data entity not found");
        auto existing = repo.findById(DataEntityId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.fields.length > 0) existing.fields = dto.fields;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(DataEntityId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Data entity not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
