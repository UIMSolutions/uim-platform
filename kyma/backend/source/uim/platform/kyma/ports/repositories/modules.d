/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.modules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of Kyma modules.
interface IModuleRepository : ITenantRepository!(KymaModule, KymaModuleId) {
  KymaModule findByName(TenantId tenantId, KymaEnvironmentId environmentId, string name);
  KymaModule[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
}
