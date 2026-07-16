/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.credentials;
// import uim.platform.credential_store.domain.entities.credential;
// import uim.platform.credential_store.domain.ports.repositories.credentials;

 
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class MemoryCredentialRepository : TenantRepository!(Credential, CredentialId), CredentialRepository {

  bool existsByName(TenantId tenantId, NamespaceId namespaceId, string name, CredentialType type) {
    return findByTenant(tenantId).any!(c => c.namespaceId == namespaceId && c.name == name && c.type == type); 
  }

  Credential findByName(TenantId tenantId, NamespaceId namespaceId, string name, CredentialType type) {
    foreach (c; findByTenant(tenantId)) {
      if (c.namespaceId == namespaceId && c.name == name && c.type == type)
        return c;
    }
    return Credential.init;
  }

  void removeByName(TenantId tenantId, NamespaceId namespaceId, string name, CredentialType type) {
    remove(findByName(tenantId, namespaceId, name, type));
  }

  size_t countByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return findByNamespace(tenantId, namespaceId).length;
  }

  Credential[] findByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    return findByTenant(tenantId).filter!(c => c.namespaceId == namespaceId).array;
  }

  void removeByNamespace(TenantId tenantId, NamespaceId namespaceId) {
    findByNamespace(tenantId, namespaceId).each!(c => remove(c));
  }

  size_t countByNamespaceAndType(TenantId tenantId, NamespaceId namespaceId, CredentialType type) {
    return findByNamespaceAndType(tenantId, namespaceId, type).length;
  }

  Credential[] findByNamespaceAndType(TenantId tenantId, NamespaceId namespaceId, CredentialType type) {
    return findByNamespace(tenantId, namespaceId).filter!(c => c.type == type).array;
  }

  void removeByNamespaceAndType(TenantId tenantId, NamespaceId namespaceId, CredentialType type) {
    findByNamespaceAndType(tenantId, namespaceId, type).each!(c => remove(c));
  }

}
