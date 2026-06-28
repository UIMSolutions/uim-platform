/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.logic_flows;

import uim.platform.build_apps;

// mixin(ShowModule!());

@safe:

class ManageLogicFlowsUseCase { // TODO: UIMUseCase {
    private LogicFlowRepository repo;

    this(LogicFlowRepository repo) {
        this.repo = repo;
    }

    LogicFlow getLogicFlow(TenantId tenantId, LogicFlowId id) {
        return repo.find(tenantId, id);
    }

    LogicFlow[] listLogicFlows(TenantId tenantId) {
        return repo.find(tenantId);
    }

    LogicFlow[] listLogicFlows(TenantId tenantId, ApplicationId applicationId) {
        return repo.findByApplication(applicationId)
            .filter!(e => e.tenantId.value == tenantId.value)
            .array;
    }

    LogicFlow[] listByPage(PageId pageId) {
        return repo.findByPage(pageId);
    }

    CommandResult createLogicFlow(LogicFlowDTO dto) {
        LogicFlow e;
        e.initEntity(dto.tenantId, dto.createdBy);

        e.id = dto.flowId;
        e.applicationId = dto.applicationId;
        e.pageId = dto.pageId;
        e.name = dto.name;
        e.description = dto.description;
        e.triggerConfig = dto.triggerConfig;
        e.nodes = dto.nodes;
        e.connections = dto.connections;
        e.variables = dto.variables;
        e.errorHandler = dto.errorHandler;
        if (!BuildAppsValidator.isValidLogicFlow(e))
            return CommandResult(false, "", "Invalid logic flow data");
            
        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateLogicFlow(LogicFlowDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.flowId);
        if (existing.isNull)
            return CommandResult(false, "", "Logic flow not found");
            
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.nodes.length > 0) existing.nodes = dto.nodes;
        if (dto.connections.length > 0) existing.connections = dto.connections;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteLogicFlow(TenantId tenantId, LogicFlowId id) {
        auto entity = repo.find(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Logic flow not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
