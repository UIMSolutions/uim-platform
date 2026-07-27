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
    private IAppDefinitionRepository repo;

    this(IAppDefinitionRepository repo) {
        this.repo = repo;
    }

    AppDefinition getDefinition(TenantId tenantId, AppDefinitionId id) {
        return repo.findById(tenantId, id);
    }

    AppDefinition[] listDefinitions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AppDefinition[] listDefinitions(TenantId tenantId, MobileApplicationId appId) {
        return repo.findByMobileApplication(tenantId, appId);
    }

    AppDefinition[] listByStatus(TenantId tenantId, DefinitionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createDefinition(AppDefinitionDTO dto) {
        auto def = AppDefinition(dto.tenantId, dto.definitionId, dto.createdBy);
        def.applicationId = dto.applicationId;
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

    CommandResult updateDefinition(AppDefinitionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.definitionId);
        if (existing.isNull)
            return CommandResult(false, "", "App definition not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.definitionContent.length > 0) existing.definitionContent = dto.definitionContent;
        if (dto.schemaVersion.length > 0) existing.schemaVersion = dto.schemaVersion;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        if (dto.targetPlatform.length > 0) existing.targetPlatform = dto.targetPlatform;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDefinition(TenantId tenantId, AppDefinitionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "App definition not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

///
unittest {
    auto repo = new IAppDefinitionRepository();
    auto usecase = new ManageAppDefinitionsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    AppDefinitionDTO createDto;
    createDto.tenantId = tenantId;
    createDto.appDefinitionId = AppDefinitionId("appDefinition-1");
    createDto.name = "Test AppDefinition";
    auto createResult = usecase.createDefinition(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listDefinitions(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getDefinition(tenantId, AppDefinitionId("appDefinition-1"));
    assert(!item.isNull);

    // Test update
    AppDefinitionDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.appDefinitionId = AppDefinitionId("appDefinition-1");
    updateDto.name = "Updated AppDefinition";
    auto updateResult = usecase.updateDefinition(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteDefinition(tenantId, AppDefinitionId("appDefinition-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listDefinitions(tenantId).length == 0);

}
