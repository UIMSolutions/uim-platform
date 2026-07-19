/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.types;

import uim.platform.redis;
mixin(ShowModule!());

@safe:

struct ServicePlanId     { mixin(IdTemplate); }
struct ConfigurationId   { mixin(IdTemplate); }
struct CacheEntryId      { mixin(IdTemplate); }
struct MetricId          { mixin(IdTemplate); }
struct BackupPolicyId    { mixin(IdTemplate); }
struct AccessControlId   { mixin(IdTemplate); }
