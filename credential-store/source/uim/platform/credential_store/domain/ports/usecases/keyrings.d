/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.usecases.keyrings;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface IManageKeyringsUseCase { 

  CommandResult createKeyring(CreateKeyringRequest r);
  CommandResult rotateKeyring(RotateKeyringRequest r);
  Credential getCredential(TenantId tenantId, CredentialId id);
  Credential[] listCredentials(TenantId tenantId, NamespaceId namespaceId);
  KeyringVersion[] getKeyringVersions(TenantId tenantId, CredentialId keyringId);
  KeyringVersion getActiveKeyringVersion(TenantId tenantId, CredentialId keyringId);
  CommandResult disableCredential(TenantId tenantId, CredentialId id);
  CommandResult deleteCredential(TenantId tenantId, CredentialId id);

}
