/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.domain.types;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

struct ServiceInstanceId { string value; mixin DomainId; }
struct ServiceBindingId  { string value; mixin DomainId; }
struct ServicePlanId     { string value; mixin DomainId; }
struct ConfigurationId   { string value; mixin DomainId; }
struct CacheEntryId      { string value; mixin DomainId; }
struct MetricId          { string value; mixin DomainId; }
struct BackupPolicyId    { string value; mixin DomainId; }
struct AccessControlId   { string value; mixin DomainId; }
