/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.environments;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of Kyma runtimes.
interface IEnvironmentRepository : ITenantRepository!(KymaEnvironment, KymaEnvironmentId) {
  KymaEnvironment findByName(TenantId tenantId, string name);
  KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  KymaEnvironment[] findByStatus(TenantId tenantId, EnvironmentStatus status);
}
