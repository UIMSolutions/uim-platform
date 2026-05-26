/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.ports.repositories.feature_flags;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

/// Port (secondary port) for feature flag persistence.
interface FeatureFlagRepository {
    /// Persist a new flag (id must already be set).
    void save(FeatureFlag flag_);

    /// Replace an existing flag.
    void update(FeatureFlag flag_);

    /// Remove a flag permanently.
    void remove(FeatureFlag flag_);

    /// Retrieve a single flag by its composite key.
    FeatureFlag findById(TenantId tenantId, FlagId id);

    /// Retrieve a flag by its unique name within a service instance.
    FeatureFlag findByName(TenantId tenantId, ServiceInstanceId instanceId, string name);

    /// All flags for a tenant.
    FeatureFlag[] findByTenant(TenantId tenantId);

    /// All flags belonging to a service instance.
    FeatureFlag[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId);

    /// All flags of a specific state within a service instance.
    FeatureFlag[] findByState(TenantId tenantId, ServiceInstanceId instanceId, FlagState state_);

    /// Count of flags in a service instance.
    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId);
}
