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
        auto err = SituationEvaluator.validate(r.tenantId, r.situationTemplateId.value, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.situationTemplateId);
        if (!existing.isNull)
            return CommandResult(false, "", "Situation template already exists");

        SituationTemplate templ;
        templ.initEntity(r.tenantId, r.situationTemplateId, r.createdBy);

        templ.name = r.name;
        templ.description = r.description;
        templ.status = TemplateStatus.draft;
        templ.entityTypeId = r.entityTypeId;
        templ.sourceSystem = r.sourceSystem;
        templ.sourceTemplateId = r.sourceTemplateId;
        templ.autoResolveTimeoutMinutes = r.autoResolveTimeoutMinutes;
        templ.escalationEnabled = r.escalationEnabled;
        templ.escalationTargetUserId = r.escalationTargetUserId;

        repo.save(templ);
        return CommandResult(true, templ.id.value, "");
    }

    SituationTemplate getSituationTemplate(TenantId tenantId, SituationTemplateId id) {
        return repo.findById(tenantId, id);
    }

    SituationTemplate[] listSituationTemplates(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SituationTemplate[] listSituationTemplates(TenantId tenantId, EntityTypeId entityTypeId) {
        return repo.findByEntityType(tenantId, entityTypeId);
    }

    CommandResult updateSituationTemplate(UpdateSituationTemplateRequest r) {
        auto templ = repo.findById(r.tenantId, r.situationTemplateId);
        if (templ.isNull)
            return CommandResult(false, "", "Situation template not found");

        templ.updatedAt = currentTimestamp();
        templ.name = r.name;
        templ.description = r.description;
        templ.entityTypeId = r.entityTypeId;
        templ.autoResolveTimeoutMinutes = r.autoResolveTimeoutMinutes;
        templ.escalationEnabled = r.escalationEnabled;
        templ.escalationTargetUserId = r.escalationTargetUserId;

        repo.update(templ);
        return CommandResult(true, templ.id.value, "");
    }

    CommandResult deleteSituationTemplate(TenantId tenantId, SituationTemplateId id) {
        auto templ = repo.findById(tenantId, id);
        if (templ.isNull)
            return CommandResult(false, "", "Situation template not found");

        repo.remove(templ);
        return CommandResult(true, templ.id.value, "");
    }
}
