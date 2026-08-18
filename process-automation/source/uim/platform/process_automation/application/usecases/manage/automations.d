/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.automations;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageAutomationsUseCase {
    private IAutomationRepository repo;

    this(IAutomationRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createAutomation(CreateAutomationRequest r) {
        if (r.automationId.isEmpty)
            return UsecaseResult(false, "", "Automation ID is required");
        if (r.name.isEmpty)
            return UsecaseResult(false, "", "Automation name is required");

        auto existing = repo.findById(r.tenantId, r.automationId);
        if (!existing.isNull)
            return UsecaseResult(false, "", "Automation already exists");

        auto a = Automation(r.tenantId, r.automationId, r.createdBy);
        a.projectId = r.projectId;
        a.name = r.name;
        a.description = r.description;
        a.status = AutomationStatus.draft;
        a.targetApplication = r.targetApplication;
        a.version_ = r.version_;

        repo.save(a);
        return UsecaseResult(true, a.id.value, "");
    }

    Automation getAutomation(TenantId tenantId, AutomationId id) {
        return repo.findById(tenantId, id);
    }

    Automation[] listAutomations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult updateAutomation(UpdateAutomationRequest r) {
        auto existing = repo.findById(r.tenantId, r.automationId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Automation not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.targetApplication = r.targetApplication;
        existing.version_ = r.version_;
        existing.updatedBy = r.updatedBy;

        
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteAutomation(TenantId tenantId, AutomationId id) {
        auto automation = repo.findById(tenantId, id);
        if (automation.isNull)
            return UsecaseResult(false, "", "Automation not found");

        repo.remove(automation);
        return UsecaseResult(true, automation.id.value, "");
    }
}
