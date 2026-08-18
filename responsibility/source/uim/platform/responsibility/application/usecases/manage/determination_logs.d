/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.determination_logs;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ManageDeterminationLogsUseCase {
    private IDeterminationLogRepository repo;

    this(IDeterminationLogRepository repo) { this.repo = repo; }

    DeterminationLog getLog(TenantId tenantId, DeterminationLogId id) {
        return repo.findById(tenantId, id);
    }

    DeterminationLog[] listLogs(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DeterminationLog[] listLogsByContext(TenantId tenantId, string contextId) {
        return repo.findByContext(tenantId, contextId);
    }

    DeterminationLog[] listLogsByObject(TenantId tenantId, string objectType, string objectId) {
        return repo.findByObject(tenantId, objectType, objectId);
    }

    UsecaseResult deleteLog(TenantId tenantId, DeterminationLogId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return UsecaseResult(false, "", "Log entry not found");
        repo.remove(e);
        return UsecaseResult(true, e.id.value, "");
    }

    UsecaseResult clearLogs(TenantId tenantId) {
        repo.removeByTenant(tenantId);
        return UsecaseResult(true, "", "");
    }
}
