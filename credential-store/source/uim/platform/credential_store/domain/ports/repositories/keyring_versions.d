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
interface KeyringVersionRepository : ITenantRepository!(KeyringVersion, KeyringVersionId) {
  KeyringVersion findActiveVersion(TenantId tenantId, CredentialId keyringId);
  KeyringVersion findByVersion(TenantId tenantId, CredentialId keyringId, long versionNumber);
  KeyringVersion[] findByKeyring(TenantId tenantId, CredentialId keyringId);
  void deactivateAll(TenantId tenantId, CredentialId keyringId);
  void removeByKeyring(TenantId tenantId, CredentialId keyringId);
  size_t countByKeyring(TenantId tenantId, CredentialId keyringId);
}
