/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.situation_instances;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageSituationInstancesUseCase : UIMUseCase {
    private SituationInstanceRepository repo;

    this(SituationInstanceRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateSituationInstanceRequest r) {
        if (r.id.isEmpty)
            return CommandResult(false, "", "Instance ID is required");
        if (r.templateid.isEmpty)
            return CommandResult(false, "", "Template ID is required");

        auto existing = repo.findById(r.id);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Situation instance already exists");

        SituationInstance i;
        i.id = r.id;
        i.templateId = r.templateId;
        i.tenantId = r.tenantId;
        i.description = r.description;
        i.status = InstanceStatus.open;
        i.entityId = r.entityId;
        i.entityTypeId = r.entityTypeId;
        i.contextData = r.contextData;
        i.assignedTo = r.assignedTo;
        i.sourceSystem = r.sourceSystem;
        i.sourceInstanceId = r.sourceInstanceId;
        i.dueAt = r.dueAt;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        i.detectedAt = now;
        i.modifiedAt = now;

        repo.save(i);
        return CommandResult(true, i.id, "");
    }

    SituationInstance get_(SituationInstanceId id) {
        return repo.findById(id);
    }

    SituationInstance[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    SituationInstance[] listByTemplate(SituationTemplateId templateId) {
        return repo.findByTemplate(templateId);
    }

    SituationInstance[] listByStatus(TenantId tenantId, InstanceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult update(UpdateSituationInstanceRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Situation instance not found");

        if (r.assignedTo.length > 0)
            existing.assignedTo = r.assignedTo;

        import core.time : MonoTime;
        existing.modifiedAt = MonoTime.currTime.ticks;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult resolve(ResolveSituationRequest r) {
        auto existing = repo.findById(r.id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Situation instance not found");

        existing.status = InstanceStatus.resolved;
        existing.resolution.resolvedBy = r.resolvedBy;
        existing.resolution.actionId = r.actionId;
        existing.resolution.ruleId = r.ruleId;
        existing.resolution.outcome = r.outcome;

        import core.time : MonoTime;
        auto now = MonoTime.currTime.ticks;
        existing.resolution.resolvedAt = now;
        existing.modifiedAt = now;

        repo.update(existing);
        return CommandResult(true, existing.id, "");
    }

    CommandResult remove(SituationInstanceId id) {
        auto existing = repo.findById(id);
        if (existing.id.isEmpty)
            return CommandResult(false, "", "Situation instance not found");

        repo.remove(id);
        return CommandResult(true, id, "");
    }
}
