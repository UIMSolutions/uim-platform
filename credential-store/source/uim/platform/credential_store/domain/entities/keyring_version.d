/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.entities.keyring_version;

import uim.platform.credential_store.domain.types;
import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
struct KeyringVersion {
  KeyringVersionId id;
  CredentialId keyringId;
  TenantId tenantId;
  long versionNumber;
  string keyMaterial;      // base64-encoded key material
  bool isActive;           // latest version is active for encryption; older only for decryption
  long createdAt;
}
