/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.infrastructure.persistence.repositories.feature_flags;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

class FeatureFlagRepository : TenantRepository!(FeatureFlag, FlagId), IFeatureFlagRepository {
    //private FeatureFlag[string] store; // key = tenantId ~ ":" ~ flagId

    // void save(FeatureFlag flag_) {
    //     store[key(flag_.tenantId, flag_.id.value)] = flag_;
    // }

    // void update(FeatureFlag flag_) {
    //     store[key(flag_.tenantId, flag_.id.value)] = flag_;
    // }

    // void remove(FeatureFlag flag_) {
        // store.remove(key(flag_.tenantId, flag_.id.value));
    // }
    
    // bool exists(TenantId tenantId, FlagId id) {
        // return findByTenant(tenantId).exists(key(tenantId, id.value));
    // }

    FeatureFlag findByName(TenantId tenantId, ServiceInstanceId instanceId, string name) {
        foreach (f; findByTenant(tenantId).values)
            if (f.tenantId == tenantId && f.instanceId == instanceId && f.name == name)
                return f;
        return FeatureFlag.init;
    }

    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return findByInstance(tenantId, instanceId).length;
    }

    FeatureFlag[] filterByInstance(FeatureFlag[] flags, ServiceInstanceId instanceId) {
        return flags.filter!(f => f.instanceId == instanceId).array;
    }

    FeatureFlag[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return filterByInstance(findByTenant(tenantId).values, instanceId);
    }

    void removeByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        findByInstance(tenantId, instanceId).each!(f => remove(f));
    }

    size_t countByState(TenantId tenantId, FlagState state_) {
        return findByState(tenantId, state_).length;
    }

    FeatureFlag[] filterByState(FeatureFlag[] flags, FlagState state_) {
        return flags.filter!(f => f.state_ == state_).array;
    }

    FeatureFlag[] findByState(TenantId tenantId, FlagState state_) {
        return filterByState(findByTenant(tenantId).values, state_);
    }

    void removeByState(TenantId tenantId, FlagState state_) {
        findByState(tenantId, state_).each!(f => remove(f));
    }

    FeatureFlag[] findByState(TenantId tenantId, ServiceInstanceId instanceId, FlagState state_) {
        return filterByInstance(findByState(tenantId, state_), instanceId);
    }

    private string key(TenantId tenantId, string id) const {
        return tenantId ~ ":" ~ id;
    }
}
