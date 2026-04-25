/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.situation_templates;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageSituationTemplatesUseCase { // TODO: UIMUseCase {
    private SituationTemplateRepository repo;

    this(SituationTemplateRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateSituationTemplateRequest r) {
        auto err = SituationEvaluator.validate(r.id, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Situation template already exists");

        SituationTemplate t;
        t.id = r.id;
        t.tenantId = r.tenantId;
        t.name = r.name;
        t.description = r.description;
        t.status = TemplateStatus.draft;
        t.entityTypeId = r.entityTypeId;
        t.sourceSystem = r.sourceSystem;
        t.sourceTemplateId = r.sourceTemplateId;
        t.autoResolveTimeoutMinutes = r.autoResolveTimeoutMinutes;
        t.escalationEnabled = r.escalationEnabled;
        t.escalationTargetUserId = r.escalationTargetUserId;
        t.createdBy = r.createdBy;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        t.createdAt = now;
        t.updatedAt = now;

        repo.save(t);
        return CommandResult(true, t.id, "");
    }

    SituationTemplate getById(SituationTemplateId id) {
        return repo.findById(id);
    }

    SituationTemplate[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SituationTemplate[] listByEntityType(TenantId tenantId, string entityTypeId) {
        return repo.findByEntityType(tenantId, entityTypeId);
    }

    CommandResult update(UpdateSituationTemplateRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Situation template not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.entityTypeId = r.entityTypeId;
        existing.autoResolveTimeoutMinutes = r.autoResolveTimeoutMinutes;
        existing.escalationEnabled = r.escalationEnabled;
        existing.escalationTargetUserId = r.escalationTargetUserId;
        existing.modifiedBy = r.modifiedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(SituationTemplateId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Situation template not found");

        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
