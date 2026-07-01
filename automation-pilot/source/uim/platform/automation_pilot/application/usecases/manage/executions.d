/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageExecutionsUseCase { // TODO: UIMUseCase {
    private ExecutionRepository repo;

    this(ExecutionRepository repo) {
        this.repo = repo;
    }

    Execution getExecution(TenantId tenantId, ExecutionId executionId) {
        return repo.findById(tenantId, executionId);
    }

    Execution[] listExecutions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Execution[] listExecutions(TenantId tenantId, CommandId commandId) {
        return repo.findByCommand(tenantId, commandId);
    }

    Execution[] listExecutions(TenantId tenantId, ExecutionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createExecution(ExecutionDTO dto) {
        auto e = Execution(dto.tenantId, dto.executionId.isNull ? ExecutionId(createId) : dto.executionId, dto.triggeredBy);
        e.commandId = dto.commandId;
        e.inputValues = dto.inputValues;
        e.triggeredBy = dto.triggeredBy;
        if (!AutomationValidator.isValidExecution(e))
            return CommandResult(false, "", "Invalid execution data");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateExecution(ExecutionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.executionId);
        if (existing.isNull)
            return CommandResult(false, "", "Execution not found");

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteExecution(TenantId tenantId, ExecutionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Execution not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
