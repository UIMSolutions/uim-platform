/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.manage_executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageExecutionsUseCase { // TODO: UIMUseCase {
    private ExecutionRepository repo;

    this(ExecutionRepository repo) {
        this.repo = repo;
    }

    Execution getById(ExecutionId id) {
        return repo.findById(id);
    }

    Execution[] list() {
        return repo.findAll();
    }

    Execution[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Execution[] listByCommand(CommandId commandId) {
        return repo.findByCommand(commandId);
    }

    Execution[] listByStatus(ExecutionStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(ExecutionDTO dto) {
        Execution e;
        e.id = ExecutionId(dto.id);
        e.tenantId = dto.tenantId;
        e.commandId = CommandId(dto.commandId);
        e.inputValues = dto.inputValues;
        e.triggeredBy = dto.triggeredBy;
        e.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidExecution(e))
            return CommandResult(false, "", "Invalid execution data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ExecutionDTO dto) {
        if (!repo.existsById(ExecutionId(dto.id)))
            return CommandResult(false, "", "Execution not found");
        auto existing = repo.findById(ExecutionId(dto.id));
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ExecutionId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Execution not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
