/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.credential;

// import uim.platform.credential_store.domain.entities.credential;
// import uim.platform.credential_store.domain.ports.repositories.credentials;
// import uim.platform.credential_store.domain.types;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class MemoryCredentialRepository : TenantRepository!(Credential, CredentialId), CredentialRepository {
  
  bool existsByName(NamespaceId namespaceId, string name, CredentialType type) {
    return findByName(namespaceId, name, type).id.value != "";
  }
  Credential findByName(NamespaceId namespaceId, string name, CredentialType type) {
    foreach (c; findAll) {
      if (c.namespaceId == namespaceId && c.name == name && c.type == type)
        return c;
    }
    return Credential.init;
  }
  void removeByName(NamespaceId namespaceId, string name, CredentialType type) {
    Credential c = findByName(namespaceId, name, type);
    if (c.id.value != "")
      remove(c.id);
  }

  size_t countByNamespace(NamespaceId namespaceId) {
    return findByNamespace(namespaceId).length;
  }
  Credential[] findByNamespace(NamespaceId namespaceId) {
    return store.values.filter!(c => c.namespaceId == namespaceId).array;
  }
  void removeByNamespace(NamespaceId namespaceId) {
    findByNamespace(namespaceId).each!(c => remove(c.id));
  }

  size_t countByNamespaceAndType(NamespaceId namespaceId, CredentialType type) {
    return findByNamespaceAndType(namespaceId, type).length;
  }
  Credential[] findByNamespaceAndType(NamespaceId namespaceId, CredentialType type) {
    return findByNamespace(namespaceId).filter!(c => c.type == type).array;
  }
  void removeByNamespaceAndType(NamespaceId namespaceId, CredentialType type) {
    findByNamespaceAndType(namespaceId, type).each!(c => remove(c.id));
  }

}
