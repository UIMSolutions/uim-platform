/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.automations;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageAutomationsUseCase : UIMUseCase {
    private AutomationRepository repo;

    this(AutomationRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateAutomationRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "Automation ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Automation name is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Automation already exists");

        Automation a;
        a.id = r.id;
        a.tenantId = r.tenantId;
        a.projectId = r.projectId;
        a.name = r.name;
        a.description = r.description;
        a.status = AutomationStatus.draft;
        a.targetApplication = r.targetApplication;
        a.version_ = r.version_;
        a.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        a.createdAt = now;
        a.modifiedAt = now;

        repo.save(a);
        return CommandResult(true, a.id, "");
    }

    Automation get_(AutomationId id) {
        return repo.findById(id);
    }

    Automation[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult update(UpdateAutomationRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Automation not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.targetApplication = r.targetApplication;
        existing.version_ = r.version_;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(AutomationId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Automation not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
