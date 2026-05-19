/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.types;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

struct ServiceInstanceId   { string value; mixin DomainId; }
struct ServiceBindingId    { string value; mixin DomainId; }
struct ServicePlanId       { string value; mixin DomainId; }
struct ConfigurationId     { string value; mixin DomainId; }
struct BackupPolicyId      { string value; mixin DomainId; }
struct DatabaseUserId      { string value; mixin DomainId; }
struct DatabaseExtensionId { string value; mixin DomainId; }
struct MaintenanceWindowId { string value; mixin DomainId; }
