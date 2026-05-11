/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.situation_actions;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageSituationActionsUseCase { // TODO: UIMUseCase {
    private SituationActionRepository repo;

    this(SituationActionRepository repo) {
        this.repo = repo;
    }

    CommandResult createSituationAction(CreateSituationActionRequest r) {
        auto err = SituationEvaluator.validate(r.tenantId, r.situationActionId, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.situationActionId);
        if (!existing.isNull)
            return CommandResult(false, "", "Situation action already exists");

        SituationAction a;
        a.initEntity(r.tenantId, r.situationActionId, r.createdBy);
        
        a.name = r.name;
        a.description = r.description;
        a.status = ActionStatus.draft;
        a.webhookUrl = r.webhookUrl;
        a.emailTemplate = r.emailTemplate;
        a.scriptContent = r.scriptContent;
        a.apiConfig.baseUrl = r.baseUrl;
        a.apiConfig.path = r.path;
        a.apiConfig.authType = r.authType;
        a.apiConfig.destinationName = r.destinationName;

        repo.save(a);
        return CommandResult(true, a.id.value, "");
    }

    SituationAction getSituationAction(TenantId tenantId, SituationActionId id) {
        return repo.findById(tenantId, id);
    }

    SituationAction[] listSituationActions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateSituationAction(UpdateSituationActionRequest r) {
        auto existing = repo.findById(r.tenantId, r.situationActionId);
        if (existing.isNull)
            return CommandResult(false, "", "Situation action not found");

        existing.name = r.name;
        existing.description = r.description;
        existing.apiConfig.baseUrl = r.baseUrl;
        existing.apiConfig.path = r.path;
        existing.apiConfig.authType = r.authType;
        existing.apiConfig.destinationName = r.destinationName;
        existing.webhookUrl = r.webhookUrl;
        existing.emailTemplate = r.emailTemplate;
        existing.updatedBy = r.updatedBy;

        import core.time : MonoTime;
        existing.updatedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSituationAction(TenantId tenantId, SituationActionId id) {
        auto action = repo.findById(tenantId, id);
        if (action.isNull)
            return CommandResult(false, "", "Situation action not found");

        repo.remove(action);
        return CommandResult(true, action.id.value, "");
    }
}
