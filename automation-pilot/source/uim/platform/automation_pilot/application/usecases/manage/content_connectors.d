/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.content_connectors;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageContentConnectorsUseCase { // TODO: UIMUseCase {
    private ContentConnectorRepository repo;

    this(ContentConnectorRepository repo) {
        this.repo = repo;
    }

    ContentConnector getContentConnector(TenantId tenantId, ContentConnectorId id) {
        return repo.findById(tenantId, id);
    }

    ContentConnector[] listContentConnectors(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createContentConnector(ContentConnectorDTO dto) {
        ContentConnector cc;
        cc.id = dto.connectorId;
        cc.tenantId = dto.tenantId;
        cc.name = dto.name;
        cc.description = dto.description;
        cc.repositoryUrl = dto.repositoryUrl;
        cc.branch = dto.branch;
        cc.path = dto.path;
        cc.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidContentConnector(cc))
            return CommandResult(false, "", "Invalid content connector data");
        repo.save(cc);
        return CommandResult(true, cc.id.value, "");
    }

    CommandResult updateContentConnector(ContentConnectorDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.connectorId);
        if (existing.isNull)
            return CommandResult(false, "", "Content connector not found");

        if (dto.name.length > 0)
            existing.name = dto.name;
        if (dto.description.length > 0)
            existing.description = dto.description;
        if (dto.repositoryUrl.length > 0)
            existing.repositoryUrl = dto.repositoryUrl;
        if (dto.branch.length > 0)
            existing.branch = dto.branch;
        if (dto.path.length > 0)
            existing.path = dto.path;
        if (!dto.updatedBy.isNull)
            existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteContentConnector(TenantId tenantId, ContentConnectorId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Content connector not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

///
unittest {
//     auto repo = new ContentConnectorRepository();
//     auto usecase = new ManageContentConnectorsUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test create
//     ContentConnectorDTO createDto;
//     createDto.tenantId = tenantId;
//     createDto.contentConnectorId = ContentConnectorId("contentConnector-1");
//     createDto.name = "Test ContentConnector";
//     auto createResult = usecase.createContentConnector(createDto);
//     assert(createResult.success, createResult.message);
// 
//     // Test list
//     auto items = usecase.listContentConnectors(tenantId);
//     assert(items.length == 1);
// 
//     // Test get
//     auto item = usecase.getContentConnector(tenantId, ContentConnectorId("contentConnector-1"));
//     assert(!item.isNull);
// 
//     // Test update
//     ContentConnectorDTO updateDto;
//     updateDto.tenantId = tenantId;
//     updateDto.contentConnectorId = ContentConnectorId("contentConnector-1");
//     updateDto.name = "Updated ContentConnector";
//     auto updateResult = usecase.updateContentConnector(updateDto);
//     assert(updateResult.success, updateResult.message);
// 
//     // Test delete
//     auto deleteResult = usecase.deleteContentConnector(tenantId, ContentConnectorId("contentConnector-1"));
//     assert(deleteResult.success, deleteResult.message);
//     assert(usecase.listContentConnectors(tenantId).length == 0);

}
