/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.credential;

import uim.platform.credential_store.domain.entities.credential;
import uim.platform.credential_store.domain.ports.repositories.credentials;
import uim.platform.credential_store.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryCredentialRepository : CredentialRepository {
  private Credential[CredentialId] store;

  bool existsById(CredentialId id) {
    return (id in store) ? true : false;
  }

  Credential findById(CredentialId id) {
    return existsById(id) ? store[id] : Credential.init;
  }

  bool existsByName(NamespaceId namespaceId, string name, CredentialType type) {
    foreach (c; store) {
      if (c.namespaceId == namespaceId && c.name == name && c.type == type)
        return true;
    }
    return false;
  }

  Credential findByName(NamespaceId namespaceId, string name, CredentialType type) {
    foreach (c; store) {
      if (c.namespaceId == namespaceId && c.name == name && c.type == type)
        return c;
    }
    return Credential.init;
  }

  Credential[] findByNamespace(NamespaceId namespaceId) {
    return store.values.filter!(c => c.namespaceId == namespaceId).array;
  }

  Credential[] findByNamespaceAndType(NamespaceId namespaceId, CredentialType type) {
    return findByNamespace(namespaceId).filter!(c => c.type == type).array;
  }

  Credential[] findByTenant(TenantId tenantId) {
    return store.values.filter!(c => c.tenantId == tenantId).array;
  }

  void save(Credential cred) {
    store[cred.id] = cred;
  }

  void update(Credential cred) {
    store[cred.id] = cred;
  }

  void remove(CredentialId id) {
    store.remove(id);
  }

  size_t countByNamespace(NamespaceId namespaceId) {
    return store.values.filter!(c => c.namespaceId == namespaceId).array.length;
  }

  size_t countByTenant(TenantId tenantId) {
    return store.values.filter!(c => c.tenantId == tenantId).array.length;
  }
}
