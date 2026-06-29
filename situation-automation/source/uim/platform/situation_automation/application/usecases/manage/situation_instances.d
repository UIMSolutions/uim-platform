/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.situation_instances;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
class ManageSituationInstancesUseCase { // TODO: UIMUseCase {
    private SituationInstanceRepository repo;

    this(SituationInstanceRepository repo) {
        this.repo = repo;
    }

    CommandResult createSituationInstance(CreateSituationInstanceRequest r) {
        if (r.situationInstanceId.isEmpty)
            return CommandResult(false, "", "Instance ID is required");
        if (r.situationTemplateId.isEmpty)
            return CommandResult(false, "", "Template ID is required");

        auto existing = repo.find(r.tenantId, r.situationInstanceId);
        if (!existing.isNull)
            return CommandResult(false, "", "Situation instance already exists");

        SituationInstance i;
        i.initEntity(r.tenantId, r.situationInstanceId);

        i.situationTemplateId = r.situationTemplateId;
        i.description = r.description;
        i.status = InstanceStatus.open;
        i.entityId = r.entityId;
        i.entityTypeId = r.entityTypeId;
        i.contextData = r.contextData;
        i.assignedTo = r.assignedTo;
        i.sourceSystem = r.sourceSystem;
        i.sourceInstanceId = r.sourceInstanceId;
        i.dueAt = r.dueAt;
        i.detectedAt = i.updatedAt;

        repo.save(i);
        return CommandResult(true, i.id.value, "");
    }

    SituationInstance getSituationInstance(TenantId tenantId, SituationInstanceId id) {
        return repo.findById(tenantId, id);
    }

    SituationInstance[] listSituationInstances(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SituationInstance[] listSituationInstances(TenantId tenantId, SituationTemplateId templateId) {
        return repo.findByTemplate(tenantId, templateId);
    }

    SituationInstance[] listSituationInstances(TenantId tenantId, InstanceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult updateSituationInstance(UpdateSituationInstanceRequest r) {
        auto existing = repo.find(r.tenantId, r.situationInstanceId);
        if (existing.isNull)
            return CommandResult(false, "", "Situation instance not found");

        if (r.assignedTo.length > 0)
            existing.assignedTo = r.assignedTo;

        
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult resolveSituationInstance(ResolveSituationRequest r) {
        auto existing = repo.find(r.tenantId, r.situationInstanceId);
        if (existing.isNull)
            return CommandResult(false, "", "Situation instance not found");
        
        existing.status = InstanceStatus.resolved;
        existing.resolution.resolvedBy = r.resolvedBy;
        existing.resolution.actionId = r.actionId;
        existing.resolution.ruleId = r.ruleId;
        existing.resolution.outcome = r.outcome;

        
        auto now = currentTimestamp;
        existing.resolution.resolvedAt = now;
        existing.updatedAt = now;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteSituationInstance(TenantId tenantId, SituationInstanceId id) {
        auto instance = repo.findById(tenantId, id);
        if (instance.isNull)
            return CommandResult(false, "", "Situation instance not found");

        repo.remove(instance);
        return CommandResult(true, instance.id.value, "");
    }
}
