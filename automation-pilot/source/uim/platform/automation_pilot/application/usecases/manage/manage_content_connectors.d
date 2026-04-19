/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.manage_content_connectors;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageContentConnectorsUseCase { // TODO: UIMUseCase {
    private ContentConnectorRepository repo;

    this(ContentConnectorRepository repo) {
        this.repo = repo;
    }

    ContentConnector getById(ContentConnectorId id) {
        return repo.findById(id);
    }

    ContentConnector[] list() {
        return repo.findAll();
    }

    ContentConnector[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(ContentConnectorDTO dto) {
        ContentConnector cc;
        cc.id = ContentConnectorId(dto.id);
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
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ContentConnectorDTO dto) {
        if (!repo.existsById(ContentConnectorId(dto.id)))
            return CommandResult(false, "", "Content connector not found");
        auto existing = repo.findById(ContentConnectorId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.repositoryUrl.length > 0) existing.repositoryUrl = dto.repositoryUrl;
        if (dto.branch.length > 0) existing.branch = dto.branch;
        if (dto.path.length > 0) existing.path = dto.path;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ContentConnectorId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Content connector not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
