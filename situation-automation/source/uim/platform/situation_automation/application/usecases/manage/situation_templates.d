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

    CommandResult createSituationTemplate(CreateSituationTemplateRequest r) {
        auto err = SituationEvaluator.validate(r.tenantId, r.situationTemplateId, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.situationTemplateId);
        if (!existing.isNull)
            return CommandResult(false, "", "Situation template already exists");

        SituationTemplate temp;
        temp.initEntity(r.tenantId, r.situationTemplateId, r.createdBy);

        temp.name = r.name;
        temp.description = r.description;
        temp.status = TemplateStatus.draft;
        temp.entityTypeId = r.entityTypeId;
        temp.sourceSystem = r.sourceSystem;
        temp.sourceTemplateId = r.sourceTemplateId;
        temp.autoResolveTimeoutMinutes = r.autoResolveTimeoutMinutes;
        temp.escalationEnabled = r.escalationEnabled;
        temp.escalationTargetUserId = r.escalationTargetUserId;

        repo.save(temp);
        return CommandResult(true, temp.id.value, "");
    }

    SituationTemplate getSituationTemplate(TenantId tenantId, SituationTemplateId id) {
        return repo.findById(tenantId, id);
    }

    SituationTemplate[] listSituationTemplates(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SituationTemplate[] listSituationTemplates(TenantId tenantId, string entityTypeId) {
        return repo.findByEntityType(tenantId, entityTypeId);
    }

    CommandResult updateSituationTemplate(UpdateSituationTemplateRequest r) {
        auto existing = repo.findById(r.tenantId, r.situationTemplateId);
        if (existing.isNull)
            return CommandResult(false, "", "Situation template not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.entityTypeId = r.entityTypeId;
        existing.autoResolveTimeoutMinutes = r.autoResolveTimeoutMinutes;
        existing.escalationEnabled = r.escalationEnabled;
        existing.escalationTargetUserId = r.escalationTargetUserId;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSituationTemplate(TenantId tenantId, SituationTemplateId id) {
        auto templ = repo.findById(tenantId, id);
        if (templ.isNull)
            return CommandResult(false, "", "Situation template not found");

        repo.remove(templ);
        return CommandResult(true, templ.id.value, "");
    }
}
