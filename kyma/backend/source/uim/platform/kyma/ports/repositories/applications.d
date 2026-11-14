/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.applications;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of connected applications.
interface IApplicationRepository : ITenantRepository!(KymaApplication, ApplicationId) {
  KymaApplication findByName(TenantId tenantId, KymaEnvironmentId environmentId, string name);
  KymaApplication[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
}
