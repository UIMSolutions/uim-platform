/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.triggers;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageTriggersUseCase { // TODO: UIMUseCase {
    private TriggerRepository repo;

    this(TriggerRepository repo) {
        this.repo = repo;
    }

    Trigger getTrigger(TenantId tenantId, TriggerId id) {
        return repo.findById(tenantId, id);
    }

    Trigger[] listTriggers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Trigger[] listTriggers(TenantId tenantId, CommandId commandId) {
        return repo.findByCommand(tenantId, commandId);
    }

    CommandResult createTrigger(TriggerDTO dto) {
        Trigger t;
        t.initEntity(dto.tenantId, dto.createdBy);

        t.id = dto.triggerId;
        t.commandId = dto.commandId;
        t.name = dto.name;
        t.description = dto.description;
        t.eventType = dto.eventType;
        t.eventSource = dto.eventSource;
        t.filterExpression = dto.filterExpression;
        t.inputMapping = dto.inputMapping;
        if (!AutomationValidator.isValidTrigger(t))
            return CommandResult(false, "", "Invalid trigger data");

        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    CommandResult updateTrigger(TriggerDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.triggerId);
        if (existing.isNull)
            return CommandResult(false, "", "Trigger not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.eventType.length > 0) existing.eventType = dto.eventType;
        if (dto.eventSource.length > 0) existing.eventSource = dto.eventSource;
        if (dto.filterExpression.length > 0) existing.filterExpression = dto.filterExpression;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteTrigger(TenantId tenantId, TriggerId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Trigger not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
