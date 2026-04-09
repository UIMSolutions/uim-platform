/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.repositories.namespaces;

import uim.platform.credential_store.domain.entities.namespace;
import uim.platform.credential_store.domain.types;

interface NamespaceRepository : ITenantRepository!(Namespace, NamespaceId) {
  Namespace findByName(TenantId tenantId, string name);
  size_t countByTenant(TenantId tenantId);
}
