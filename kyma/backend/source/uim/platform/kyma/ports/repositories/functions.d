/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.functions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of serverless functions (namespace scoped).
interface IFunctionRepository : ITenantRepository!(ServerlessFunction, ServerlessFunctionId) {
  ServerlessFunction findByName(TenantId tenantId, NamespaceId namespaceId, string name);
  ServerlessFunction[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  ServerlessFunction[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
}
