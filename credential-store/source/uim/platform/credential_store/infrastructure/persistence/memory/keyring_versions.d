/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.keyring_versions;
// import uim.platform.credential_store.domain.entities.keyring_version;
// import uim.platform.credential_store.domain.ports.repositories.keyring_versions;

 
import uim.platform.credential_store;

// mixin(ShowModule!());

@safe:
class MemoryKeyringVersionRepository : TentRepository!(KeyringVersion, KeyringVersionId), KeyringVersionRepository {

  KeyringVersion findActiveVersion(TenantId tenantId, CredentialId keyringId) {
    foreach (v; findByTenant(tenantId))
      if (v.keyringId == keyringId && v.isActive)
        return v;
    return KeyringVersion.init;
  }

  KeyringVersion findByVersion(TenantId tenantId, CredentialId keyringId, long versionNumber) {
    foreach (v; findByTenant(tenantId))
      if (v.keyringId == keyringId && v.versionNumber == versionNumber)
        return v;
    return KeyringVersion.init;
  }

  size_t countByKeyring(TenantId tenantId, CredentialId keyringId) {
    return findByKeyring(tenantId, keyringId).length;
  }

  KeyringVersion[] findByKeyring(TenantId tenantId, CredentialId keyringId) {
    return findByTenant(tenantId).filter!(v => v.keyringId == keyringId).array;
  }

  void removeByKeyring(TenantId tenantId, CredentialId keyringId) {
    findByKeyring(tenantId, keyringId).each!(v => remove(v));
  }

  void deactivateAll(TenantId tenantId, CredentialId keyringId) {
    findByKeyring(tenantId, keyringId).each!(v => v.isActive = false);
  }

}
