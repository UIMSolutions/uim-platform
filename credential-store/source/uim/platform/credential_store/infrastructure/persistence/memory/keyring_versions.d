/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.infrastructure.persistence.memory.keyring_versions;

// import uim.platform.credential_store.domain.entities.keyring_version;
// import uim.platform.credential_store.domain.ports.repositories.keyring_versions;
// import uim.platform.credential_store.domain.types;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
class MemoryKeyringVersionRepository : TenantRepository!(KeyringVersion, KeyringVersionId), KeyringVersionRepository {

  KeyringVersion findActiveVersion(CredentialId keyringId) {
    foreach (v; findAll)
      if (v.keyringId == keyringId && v.isActive)
        return v;
    return KeyringVersion.init;
  }

  KeyringVersion findByVersion(CredentialId keyringId, long versionNumber) {
    foreach (v; findAll)
      if (v.keyringId == keyringId && v.versionNumber == versionNumber)
        return v;
    return KeyringVersion.init;
  }

  size_t countByKeyring(CredentialId keyringId) {
    return findByKeyring(keyringId).length;
  }

  KeyringVersion[] findByKeyring(CredentialId keyringId) {
    return findAll().filter!(v => v.keyringId == keyringId).array;
  }

  void removeByKeyring(CredentialId keyringId) {
    findByKeyring(keyringId).each!(v => remove(v));
  }

  void deactivateAll(CredentialId keyringId) {
    findByKeyring(keyringId).each!(v => v.isActive = false);
  }

}
