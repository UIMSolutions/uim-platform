/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.repositories.credentials;

// import uim.platform.credential_store.domain.entities.credential;
// import uim.platform.credential_store.domain.types;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface CredentialRepository : ITenantRepository!(Credential, CredentialId) {

  bool existsByName(NamespaceId namespaceId, string name, CredentialType type);
  Credential findByName(NamespaceId namespaceId, string name, CredentialType type);
  void removeByName(NamespaceId namespaceId, string name, CredentialType type);

  size_t countByNamespace(NamespaceId namespaceId);
  Credential[] findByNamespace(NamespaceId namespaceId);
  void removeByNamespace(NamespaceId namespaceId);

  size_t countByNamespaceAndType(NamespaceId namespaceId, CredentialType type);
  Credential[] findByNamespaceAndType(NamespaceId namespaceId, CredentialType type);
  void removeByNamespaceAndType(NamespaceId namespaceId, CredentialType type);

}
