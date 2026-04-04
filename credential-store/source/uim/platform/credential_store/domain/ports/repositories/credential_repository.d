/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.repositories.credentials;

import uim.platform.credential_store.domain.entities.credential;
import uim.platform.credential_store.domain.types;

interface CredentialRepository {
  Credential findById(CredentialId id);
  Credential findByName(NamespaceId namespaceId, string name, CredentialType type);
  Credential[] findByNamespace(NamespaceId namespaceId);
  Credential[] findByNamespaceAndType(NamespaceId namespaceId, CredentialType type);
  Credential[] findByTenant(TenantId tenantId);
  void save(Credential cred);
  void update(Credential cred);
  void remove(CredentialId id);
  long countByNamespace(NamespaceId namespaceId);
  long countByTenant(TenantId tenantId);
}
