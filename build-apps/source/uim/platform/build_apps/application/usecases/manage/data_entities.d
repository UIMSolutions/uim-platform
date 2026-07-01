/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.data_entities;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageDataEntitiesUseCase { // TODO: UIMUseCase {
    private DataEntityRepository repo;

    this(DataEntityRepository repo) {
        this.repo = repo;
    }

    DataEntity getDataEntity(TenantId tenantId, DataEntityId id) {
        return repo.findById(tenantId, id);
    }

    DataEntity[] listDataEntities(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataEntity[] listDataEntities(TenantId tenantId, ApplicationId applicationId) {
        return repo.findByApplication(tenantId, applicationId);
    }

    CommandResult createDataEntity(DataEntityDTO dto) {
        auto e = DataEntity(dto.tenantId, dto.entityId.isNull ? DataEntityId(createId()) : dto.entityId, dto.createdBy);
        e.applicationId = dto.applicationId;
        e.name = dto.name;
        e.description = dto.description;
        e.fields = dto.fields;
        e.primaryKey = dto.primaryKey;
        e.indexes = dto.indexes;
        e.validationRules = dto.validationRules;
        e.defaultValues = dto.defaultValues;
        e.relations = dto.relations;
        if (!BuildAppsValidator.isValidDataEntity(e))
            return CommandResult(false, "", "Invalid data entity");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateDataEntity(DataEntityDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.entityId);
        if (existing.isNull)
            return CommandResult(false, "", "Data entity not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.fields.length > 0) existing.fields = dto.fields;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDataEntity(TenantId tenantId, DataEntityId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Data entity not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
