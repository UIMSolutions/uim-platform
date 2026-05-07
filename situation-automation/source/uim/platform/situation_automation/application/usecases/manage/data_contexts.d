/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.data_contexts;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageDataContextsUseCase { // TODO: UIMUseCase {
    private DataContextRepository repo;

    this(DataContextRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateDataContextRequest r) {
        if (r.isNull)
            return CommandResult(false, "", "Data context ID is required");
        if (r.instanceId.isEmpty)
            return CommandResult(false, "", "Instance ID is required");

        auto existing = repo.findById(r.id);
        if (!existing.isNull)
            return CommandResult(false, "", "Data context already exists");

        DataContext d;
        d.id = r.id;
        d.instanceId = r.instanceId;
        d.tenantId = r.tenantId;
        d.entityId = r.entityId;
        d.entityTypeId = r.entityTypeId;
        d.data = r.data;
        d.sourceSystem = r.sourceSystem;
        d.containsPersonalData = r.containsPersonalData;
        d.expiresAt = r.expiresAt;

        import core.time : MonoTime;
        d.capturedAt = MonoTime.currTime.ticks;

        repo.save(d);
        return CommandResult(true, d.id.value, "");
    }

    DataContext getById(DataContextId id) {
        return repo.findById(tenantId, id);
    }

    DataContext[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataContext[] listByInstance(SituationInstanceId instanceId) {
        return repo.findByInstance(instanceId);
    }

    CommandResult deleteDataContext(DataContextId id) {
        auto context = repo.findById(tenantId, id);
        if (context.isNull)
            return CommandResult(false, "", "Data context not found");

        repo.remove(context);
        return CommandResult(true, context.id.value, "");
    }

    CommandResult deletePersonalData(TenantId tenantId) {
        auto items = repo.findPersonalData(tenantId);
        foreach (item; items) {
            repo.remove(item.id);
        }
        return CommandResult(true, "", "");
    }
}
