/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.repositories.keyring_versions;

// import uim.platform.credential_store.domain.entities.keyring_version;
// import uim.platform.credential_store.domain.types;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface KeyringVersionRepository {
  KeyringVersion findById(KeyringVersionId id);
  KeyringVersion findActiveVersion(CredentialId keyringId);
  KeyringVersion findByVersion(CredentialId keyringId, long versionNumber);
  KeyringVersion[] findByKeyring(CredentialId keyringId);
  void save(KeyringVersion ver);
  void deactivateAll(CredentialId keyringId);
  void remove(KeyringVersionId id);
  void removeByKeyring(CredentialId keyringId);
  size_t countByKeyring(CredentialId keyringId);
}
