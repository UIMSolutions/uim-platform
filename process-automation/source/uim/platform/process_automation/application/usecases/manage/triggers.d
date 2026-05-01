/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.triggers;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageTriggersUseCase { // TODO: UIMUseCase {
    private TriggerRepository repo;

    this(TriggerRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateTriggerRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "Trigger ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Trigger name is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Trigger already exists");

        Trigger t;
        t.id = r.id;
        t.processId = r.processId;
        t.tenantId = r.tenantId;
        t.name = r.name;
        t.description = r.description;
        t.status = TriggerStatus.active;
        t.eventType = r.eventType;
        t.eventSource = r.eventSource;
        t.filterExpression = r.filterExpression;
        t.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        t.createdAt = now;
        t.updatedAt = now;

        repo.save(t);
        return CommandResult(true, t.id, "");
    }

    Trigger getById(TriggerId id) {
        return repo.findById(id);
    }

    Trigger[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Trigger[] listByProcess(ProcessId processId) {
        return repo.findByProcess(processId);
    }

    CommandResult update(UpdateTriggerRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.isNull)
            return CommandResult(false, "", "Trigger not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.eventType = r.eventType;
        existing.filterExpression = r.filterExpression;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(TriggerId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Trigger not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
