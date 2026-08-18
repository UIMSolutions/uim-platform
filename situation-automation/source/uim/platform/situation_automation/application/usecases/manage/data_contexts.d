/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.application.usecases.manage.data_contexts;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
class ManageDataContextsUseCase {
    private IDataContextRepository repo;

    this(IDataContextRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createDataContext(CreateDataContextRequest r) {
        if (r.dataContextId.isEmpty)
            return UsecaseResult(false, "", "Data context ID is required");
        if (r.situationInstanceId.isEmpty)
            return UsecaseResult(false, "", "Instance ID is required");

        auto existing = repo.findById(r.tenantId, r.dataContextId);
        if (!existing.isNull)
            return UsecaseResult(false, "", "Data context already exists");

        auto d = DataContext(r.tenantId); //, r.dataContextId);
        d.instanceId = r.situationInstanceId;
        d.entityId = r.entityId;
        d.entityTypeId = r.entityTypeId;
        d.data = r.data;
        d.sourceSystem = r.sourceSystem;
        d.containsPersonalData = r.containsPersonalData;
        d.expiresAt = r.expiresAt;

        
        d.capturedAt = currentTimestamp;

        repo.save(d);
        return UsecaseResult(true, d.id.value, "");
    }

    DataContext getDataContext(TenantId tenantId, DataContextId id) {
        return repo.findById(tenantId, id);
    }

    DataContext[] listDataContexts(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DataContext[] listDataContexts(TenantId tenantId, SituationInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    UsecaseResult deleteDataContext(TenantId tenantId, DataContextId id) {
        auto context = repo.findById(tenantId, id);
        if (context.isNull)
            return UsecaseResult(false, "", "Data context not found");

        repo.remove(context);
        return UsecaseResult(true, context.id.value, "");
    }

    UsecaseResult deletePersonalData(TenantId tenantId) {
        auto items = repo.findByPersonalData(tenantId);
        foreach (item; items) {
            repo.remove(item);
        }
        return UsecaseResult(true, "", "");
    }
}
