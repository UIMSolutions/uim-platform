/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.application.usecases.manage.manage_triggers;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class ManageTriggersUseCase : UIMUseCase {
    private TriggerRepository repo;

    this(TriggerRepository repo) {
        this.repo = repo;
    }

    Trigger getById(TriggerId id) {
        return repo.findById(id);
    }

    Trigger[] list() {
        return repo.findAll();
    }

    Trigger[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Trigger[] listByCommand(CommandId commandId) {
        return repo.findByCommand(commandId);
    }

    CommandResult create(TriggerDTO dto) {
        Trigger t;
        t.id = TriggerId(dto.id);
        t.tenantId = dto.tenantId;
        t.commandId = CommandId(dto.commandId);
        t.name = dto.name;
        t.description = dto.description;
        t.eventType = dto.eventType;
        t.eventSource = dto.eventSource;
        t.filterExpression = dto.filterExpression;
        t.inputMapping = dto.inputMapping;
        t.createdBy = dto.createdBy;
        if (!AutomationValidator.isValidTrigger(t))
            return CommandResult(false, "", "Invalid trigger data");
        repo.save(t);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(TriggerDTO dto) {
        if (!repo.existsById(TriggerId(dto.id)))
            return CommandResult(false, "", "Trigger not found");
        auto existing = repo.findById(TriggerId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.eventType.length > 0) existing.eventType = dto.eventType;
        if (dto.eventSource.length > 0) existing.eventSource = dto.eventSource;
        if (dto.filterExpression.length > 0) existing.filterExpression = dto.filterExpression;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(TriggerId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Trigger not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
