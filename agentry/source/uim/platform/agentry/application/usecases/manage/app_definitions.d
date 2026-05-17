/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.app_definitions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageAppDefinitionsUseCase {
    private AppDefinitionRepository repo;

    this(AppDefinitionRepository repo) {
        this.repo = repo;
    }

    AppDefinition getAppDefinition(TenantId tenantId, AppDefinitionId id) {
        return repo.findById(tenantId, id);
    }

    AppDefinition[] listAppDefinitions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AppDefinition[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return repo.findByMobileApplication(tenantId, appId);
    }

    AppDefinition[] listByStatus(TenantId tenantId, DefinitionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createAppDefinition(AppDefinitionDTO dto) {
        AppDefinition def;
        def.initEntity(dto.tenantId, dto.createdBy);
        def.id = dto.definitionId;
        def.mobileApplicationId = dto.mobileApplicationId;
        def.name = dto.name;
        def.description = dto.description;
        def.definitionContent = dto.definitionContent;
        def.definitionFormat = dto.definitionFormat;
        def.schemaVersion = dto.schemaVersion;
        def.authoredBy = dto.authoredBy;
        def.targetPlatform = dto.targetPlatform;
        def.businessObjectModel = dto.businessObjectModel;

        if (!AgentryValidator.isValidAppDefinition(def))
            return CommandResult(false, "", "Invalid app definition data");

        repo.save(def);
        return CommandResult(true, def.id.value, "");
    }

    CommandResult updateAppDefinition(AppDefinitionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.definitionId);
        if (existing.isNull)
            return CommandResult(false, "", "App definition not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.definitionContent.length > 0) existing.definitionContent = dto.definitionContent;
        if (dto.schemaVersion.length > 0) existing.schemaVersion = dto.schemaVersion;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteAppDefinition(TenantId tenantId, AppDefinitionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "App definition not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
