/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.triggers;

import uim.platform.process_automation;

// mixin(ShowModule!());

@safe:
class ManageTriggersUseCase { // TODO: UIMUseCase {
    private TriggerRepository repo;

    this(TriggerRepository repo) {
        this.repo = repo;
    }

    CommandResult createTrigger(CreateTriggerRequest r) {
        if (r.triggerId.isEmpty)
            return CommandResult(false, "", "Trigger ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Trigger name is required");

        auto existing = repo.findById(r.tenantId, r.triggerId);
        if (!existing.isNull)
            return CommandResult(false, "", "Trigger already exists");

        Trigger t;
        t.initEntity(r.tenantId, r.createdBy);
        t.id = r.triggerId;
        t.processId = r.processId;
        t.name = r.name;
        t.description = r.description;
        t.status = TriggerStatus.active;
        t.eventType = r.eventType;
        t.eventSource = r.eventSource;
        t.filterExpression = r.filterExpression;

        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    Trigger getTrigger(TenantId tenantId, TriggerId triggerId) {
        return repo.findById(tenantId, triggerId);
    }

    Trigger[] listTriggers(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Trigger[] listTriggers(TenantId tenantId, ProcessId processId) {
        return repo.findByProcess(tenantId, processId);
    }

    CommandResult updateTrigger(UpdateTriggerRequest r) {
        auto existing = repo.findById(r.tenantId, r.triggerId);
        if (existing.isNull)
            return CommandResult(false, "", "Trigger not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.eventType = r.eventType;
        existing.filterExpression = r.filterExpression;

        import core.time : MonoTime;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteTrigger(TenantId tenantId, TriggerId triggerId) {
        auto trigger = repo.findById(tenantId, triggerId);
        if (trigger.isNull)
            return CommandResult(false, "", "Trigger not found");

        repo.remove(trigger);
        return CommandResult(true, trigger.id.value, "");
    }
}
