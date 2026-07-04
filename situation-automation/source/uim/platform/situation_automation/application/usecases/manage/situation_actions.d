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
        auto err = SituationEvaluator.validate(r.tenantId, r.situationActionId.value, r.name);
        if (err.length > 0)
            return CommandResult(false, "", err);

        auto existing = repo.findById(r.tenantId, r.situationActionId);
        if (!existing.isNull)
            return CommandResult(false, "", "Situation action already exists");

        SituationAction action;
        action.initEntity(r.tenantId, r.situationActionId, r.createdBy);
        
        action.name = r.name;
        action.description = r.description;
        action.status = ActionStatus.draft;
        action.webhookUrl = r.webhookUrl;
        action.emailTemplate = r.emailTemplate;
        action.scriptContent = r.scriptContent;
        action.apiConfig.baseUrl = r.baseUrl;
        action.apiConfig.path = r.path;
        action.apiConfig.authType = r.authType;
        action.apiConfig.destinationName = r.destinationName;

        repo.save(action);
        return CommandResult(true, action.id.value, "");
    }

    SituationAction getSituationAction(TenantId tenantId, SituationActionId id) {
        return repo.findById(tenantId, id);
    }

    SituationAction[] listSituationActions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult updateSituationAction(UpdateSituationActionRequest r) {
        auto action = repo.findById(r.tenantId, r.situationActionId);
        if (action.isNull)
            return CommandResult(false, "", "Situation action not found");

        action.updatedAt = currentTimestamp();
        action.updatedBy = r.updatedBy;
        action.name = r.name;
        action.description = r.description;
        action.apiConfig.baseUrl = r.baseUrl;
        action.apiConfig.path = r.path;
        action.apiConfig.authType = r.authType;
        action.apiConfig.destinationName = r.destinationName;
        action.webhookUrl = r.webhookUrl;
        action.emailTemplate = r.emailTemplate;

        repo.update(action);
        return CommandResult(true, action.id.value, "");
    }

    CommandResult deleteSituationAction(TenantId tenantId, SituationActionId id) {
        auto action = repo.findById(tenantId, id);
        if (action.isNull)
            return CommandResult(false, "", "Situation action not found");

        repo.remove(action);
        return CommandResult(true, action.id.value, "");
    }
}
