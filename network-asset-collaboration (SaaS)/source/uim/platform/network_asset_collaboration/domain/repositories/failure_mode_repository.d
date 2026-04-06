/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.repositories.failure_mode_repository;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

interface FailureModeRepository {
    FailureMode[] findAll();
    FailureMode* findById(FailureModeId id);
    FailureMode[] findByTenant(TenantId tenantId);
    FailureMode[] findByModel(string modelId);
    FailureMode[] findBySeverity(FailureSeverity severity);
    void save(FailureMode failureMode);
    void update(FailureMode failureMode);
    void remove(FailureModeId id);
}
