/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.memory.feature_flag_repo;

import uim.platform.feature_flags;
import std.algorithm : filter, find;
import std.array     : array;

// mixin(ShowModule!());

@safe:

class MemoryFeatureFlagRepository : FeatureFlagRepository {
    private FeatureFlag[string] store; // key = tenantId ~ ":" ~ flagId

    void save(FeatureFlag flag_) {
        store[key(flag_.tenantId, flag_.id.value)] = flag_;
    }

    void update(FeatureFlag flag_) {
        store[key(flag_.tenantId, flag_.id.value)] = flag_;
    }

    void remove(FeatureFlag flag_) {
        store.remove(key(flag_.tenantId, flag_.id.value));
    }

    FeatureFlag findById(TenantId tenantId, FlagId id) {
        auto k = key(tenantId, id.value);
        auto p = k in store;
        return p ? *p : FeatureFlag.init;
    }

    FeatureFlag findByName(TenantId tenantId, ServiceInstanceId instanceId, string name) {
        foreach (f; store.values)
            if (f.tenantId == tenantId && f.instanceId == instanceId && f.name == name)
                return f;
        return FeatureFlag.init;
    }

    FeatureFlag[] findByTenant(TenantId tenantId) {
        return store.values.filter!(f => f.tenantId == tenantId).array;
    }

    FeatureFlag[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return store.values
            .filter!(f => f.tenantId == tenantId && f.instanceId == instanceId)
            .array;
    }

    FeatureFlag[] findByState(TenantId tenantId, ServiceInstanceId instanceId, FlagState state_) {
        return store.values
            .filter!(f => f.tenantId == tenantId && f.instanceId == instanceId && f.state_ == state_)
            .array;
    }

    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }

    private string key(TenantId tenantId, string id) const {
        return tenantId ~ ":" ~ id;
    }
}
