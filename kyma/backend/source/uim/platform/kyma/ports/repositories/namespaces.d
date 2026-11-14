/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.namespaces;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of namespaces.
interface INamespaceRepository : ITenantRepository!(KymaNamespace, NamespaceId) {
  KymaNamespace findByName(TenantId tenantId, KymaEnvironmentId environmentId, string name);
  KymaNamespace[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
}
