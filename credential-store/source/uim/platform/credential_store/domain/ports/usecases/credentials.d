/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.ports.usecases.credentials;

import uim.platform.credential_store;

mixin(ShowModule!());

@safe:
interface IManageCredentialsUseCase { 
  
  CommandResult createCredential(CreateCredentialRequest r);
  CommandResult updateCredential(TenantId tenantId, CredentialId id, UpdateCredentialRequest r);
  Credential getCredential(TenantId tenantId, CredentialId id);
  Credential getCredentialByName(TenantId tenantId, NamespaceId namespaceId, string name, string type);
  Credential[] listCredentials(TenantId tenantId, NamespaceId namespaceId);
  Credential[] listCredentials(TenantId tenantId, NamespaceId namespaceId, string type);
  CommandResult deleteCredential(TenantId tenantId, CredentialId id);
  size_t countCredentialsByNamespace(TenantId tenantId, NamespaceId namespaceId);
  size_t countCredentialsByTenant(TenantId tenantId);

}
