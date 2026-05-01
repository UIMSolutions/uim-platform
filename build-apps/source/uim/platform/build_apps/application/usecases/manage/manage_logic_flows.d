/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.manage_logic_flows;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageLogicFlowsUseCase { // TODO: UIMUseCase {
    private LogicFlowRepository repo;

    this(LogicFlowRepository repo) {
        this.repo = repo;
    }

    LogicFlow getById(LogicFlowId id) {
        return repo.findById(id);
    }

    LogicFlow[] list() {
        return repo.findAll();
    }

    LogicFlow[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    LogicFlow[] listByApplication(ApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    LogicFlow[] listByPage(PageId pageId) {
        return repo.findByPage(pageId);
    }

    CommandResult create(LogicFlowDTO dto) {
        LogicFlow e;
        e.id = LogicFlowId(dto.id);
        e.tenantId = dto.tenantId;
        e.applicationId = ApplicationId(dto.applicationId);
        e.pageId = PageId(dto.pageId);
        e.name = dto.name;
        e.description = dto.description;
        e.triggerConfig = dto.triggerConfig;
        e.nodes = dto.nodes;
        e.connections = dto.connections;
        e.variables = dto.variables;
        e.errorHandler = dto.errorHandler;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidLogicFlow(e))
            return CommandResult(false, "", "Invalid logic flow data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(LogicFlowDTO dto) {
        if (!repo.existsById(LogicFlowId(dto.id)))
            return CommandResult(false, "", "Logic flow not found");
        auto existing = repo.findById(LogicFlowId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.nodes.length > 0) existing.nodes = dto.nodes;
        if (dto.connections.length > 0) existing.connections = dto.connections;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(LogicFlowId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Logic flow not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
