/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.ports.usecases.feature_flags;

import uim.platform.feature_flags;
import std.conv      : to, ConvException;
import std.algorithm : map;
import std.array     : array;
import core.time     : MonoTime;

mixin(ShowModule!());

@safe:

interface IManageFeatureFlagsUseCase {

    FeatureFlag getFlag(TenantId tenantId, FlagId id);

    FeatureFlag getFlagByName(TenantId tenantId, ServiceInstanceId instanceId, string name);

    FeatureFlag[] listFlags(TenantId tenantId);

    FeatureFlag[] listFlagsByInstance(TenantId tenantId, ServiceInstanceId instanceId);

    FlagResult createFlag(CreateFeatureFlagRequest req);

    FlagResult updateFlag(TenantId tenantId, FlagId id, UpdateFeatureFlagRequest req);

    FlagResult patchFlagState(TenantId tenantId, FlagId id, PatchFeatureFlagRequest req);

    FlagResult deleteFlag(TenantId tenantId, FlagId id, string deletedBy = "");

}
