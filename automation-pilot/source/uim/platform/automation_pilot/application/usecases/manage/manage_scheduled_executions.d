/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.scheduled_executions;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageScheduledExecutionsUseCase { // TODO: UIMUseCase {
    private ScheduledExecutionRepository repo;

    this(ScheduledExecutionRepository repo) {
        this.repo = repo;
    }

    ScheduledExecution getById(ScheduledExecutionId id) {
        return repo.findById(id);
    }

    ScheduledExecution[] list() {
        return repo.findAll();
    }

    ScheduledExecution[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ScheduledExecution[] listByCommand(CommandId commandId) {
        return repo.findByCommand(commandId);
    }

    CommandResult create(ScheduledExecutionDTO dto) {
        ScheduledExecution se;
        se.id = ScheduledExecutionId(dto.id);
        se.tenantId = dto.tenantId;
        se.commandId = CommandId(dto.commandId);
        se.cronExpression = dto.cronExpression;
        se.scheduledAt = dto.scheduledAt;
        se.inputValues = dto.inputValues;
        se.description = dto.description;
        se.maxRetries = dto.maxRetries;
        se.retryDelay = dto.retryDelay;
        se.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidScheduledExecution(se))
            return CommandResult(false, "", "Invalid scheduled execution data");
        repo.save(se);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ScheduledExecutionDTO dto) {
        if (!repo.existsById(ScheduledExecutionId(dto.id)))
            return CommandResult(false, "", "Scheduled execution not found");
        auto existing = repo.findById(ScheduledExecutionId(dto.id));
        if (dto.cronExpression.length > 0) existing.cronExpression = dto.cronExpression;
        if (dto.scheduledAt > 0) existing.scheduledAt = dto.scheduledAt;
        if (dto.description.length > 0) existing.description = dto.description;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ScheduledExecutionId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Scheduled execution not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
