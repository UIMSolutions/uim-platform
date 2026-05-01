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
class MemoryKeyringVersionRepository : KeyringVersionRepository {
  private KeyringVersion[] store;

  bool existsById(KeyringVersionId id) {
    return store.any!(v => v.id == id);
  }

  KeyringVersion findById(KeyringVersionId id) {
    foreach (v; findAll)
      if (v.id == id)
        return v;
    return KeyringVersion.init;
  }

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

  KeyringVersion[] findByKeyring(CredentialId keyringId) {
    return findAll().filter!(v => v.keyringId == keyringId).array;
  }

  void save(KeyringVersion ver) {
    store ~= ver;
  }

  void deactivateAll(CredentialId keyringId) {
    foreach (v; findAll) {
      if (v.keyringId == keyringId)
        v.isActive = false;
    }
  }

  void remove(KeyringVersionId id) {
    store = findAll().filter!(v => v.id != id).array;
  }

  void removeByKeyring(CredentialId keyringId) {
    store = findAll().filter!(v => v.keyringId != keyringId).array;
  }

  size_t countByKeyring(CredentialId keyringId) {
    return findAll().filter!(v => v.keyringId == keyringId).array.length;
  }
}
