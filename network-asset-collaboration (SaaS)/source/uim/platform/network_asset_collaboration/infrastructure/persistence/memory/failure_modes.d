/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.infrastructure.persistence.memory.failure_modes;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class MemoryFailureModeRepository : FailureModeRepository {
    private FailureMode[] store;

    FailureMode[] findAll() { return store; }

    FailureMode* findById(FailureModeId id) {
        foreach (ref fm; store)
            if (fm.id == id) return &fm;
        return null;
    }

    FailureMode[] findByTenant(TenantId tenantId) {
        FailureMode[] result;
        foreach (ref fm; store)
            if (fm.tenantId == tenantId) result ~= fm;
        return result;
    }

    FailureMode[] findByModel(string modelId) {
        FailureMode[] result;
        foreach (ref fm; store)
            if (fm.modelId == modelId) result ~= fm;
        return result;
    }

    FailureMode[] findBySeverity(FailureSeverity severity) {
        FailureMode[] result;
        foreach (ref fm; store)
            if (fm.severity == severity) result ~= fm;
        return result;
    }

    void save(FailureMode failureMode) { store ~= failureMode; }

    void update(FailureMode failureMode) {
        foreach (ref fm; store)
            if (fm.id == failureMode.id) { fm = failureMode; return; }
    }

    void remove(FailureModeId id) {
        import std.algorithm : remove;
        store = store.remove!(fm => fm.id == id);
    }
}
