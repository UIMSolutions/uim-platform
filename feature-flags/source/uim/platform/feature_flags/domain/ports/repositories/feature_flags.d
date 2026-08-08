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
interface IFeatureFlagRepository :  ITenantRepository!(FeatureFlag, FlagId) {

    /// Retrieve a flag by its unique name within a service instance.
    FeatureFlag findByName(TenantId tenantId, ServiceInstanceId instanceId, string name);

    /// Count of flags in a service instance.
    size_t countByInstance(TenantId tenantId, ServiceInstanceId instanceId);

    /// All flags belonging to a service instance.
    FeatureFlag[] findByInstance(TenantId tenantId, ServiceInstanceId instanceId);

    /// All flags of a specific state within a service instance.
    FeatureFlag[] findByState(TenantId tenantId, ServiceInstanceId instanceId, FlagState state_);

}
