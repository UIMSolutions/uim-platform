/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.types;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

struct ServiceInstanceId   { string value; mixin IdTemplate; }
struct ServiceBindingId    { string value; mixin IdTemplate; }
struct ServicePlanId       { string value; mixin IdTemplate; }
struct ConfigurationId     { string value; mixin IdTemplate; }
struct BackupPolicyId      { string value; mixin IdTemplate; }
struct DatabaseUserId      { string value; mixin IdTemplate; }
struct DatabaseExtensionId { string value; mixin IdTemplate; }
struct MaintenanceWindowId { string value; mixin IdTemplate; }
