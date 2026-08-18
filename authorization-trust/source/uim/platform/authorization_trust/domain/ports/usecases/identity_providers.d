/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.domain.ports.usecases.identity_providers;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ManageIdentityProvidersUseCase {
  protected IIdentityProviderRepository repo;

  this(IIdentityProviderRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createProvider(CreateIdentityProviderRequest r) {
    if (r.alias_.length == 0)
      return UsecaseResult(false, "", "IdP alias is required");
    if (repo.existsByAlias(r.tenantId, r.alias_))
      return UsecaseResult(false, "", "An identity provider with this alias already exists");

    import std.uuid : randomUUID;
    IdentityProvider idp;
    idp.id          = generateId;
    idp.alias_      = r.alias_;
    idp.displayName = r.displayName;
    idp.idpType     = r.idpType.toIdpType;
    idp.metadataUrl = r.metadataUrl;
    idp.entityId    = r.entityId;
    idp.ssoUrl      = r.ssoUrl;
    idp.sloUrl      = r.sloUrl;
    idp.signingCert = r.signingCert;
    idp.isActive    = r.isActive;
    idp.isDefault   = r.isDefault;
    idp.createdAt   = currentTimestamp();
    idp.updatedAt   = idp.createdAt;

    repo.save(idp);
    return UsecaseResult(true, idp.id.value, "");
  }

  UsecaseResult updateProvider(UpdateIdentityProviderRequest r) {
    auto idp = repo.findById(r.tenantId, r.providerId);
    if (idp.isNull)
      return UsecaseResult(false, "", "Identity provider not found");

    if (r.displayName.length > 0) idp.displayName = r.displayName;
    if (r.metadataUrl.length > 0) idp.metadataUrl = r.metadataUrl;
    if (r.ssoUrl.length > 0)      idp.ssoUrl      = r.ssoUrl;
    if (r.sloUrl.length > 0)      idp.sloUrl      = r.sloUrl;
    if (r.signingCert.length > 0) idp.signingCert = r.signingCert;
    idp.isActive  = r.isActive;
    idp.isDefault = r.isDefault;
    idp.updatedAt = currentTimestamp();

    repo.update(idp);
    return UsecaseResult(true, idp.id.value, "");
  }

  UsecaseResult deleteProvider(TenantId tenantId, IdentityProviderId id) {
    auto provider = repo.findById(tenantId, id);
    if (provider.isNull)
      return UsecaseResult(false, "", "Identity provider not found");
      
    repo.remove(provider);
    return UsecaseResult(true, provider.id.value, "");
  }

  IdentityProvider getProvider(TenantId tenantId, IdentityProviderId id) {
    return repo.findById(tenantId, id);
  }

  IdentityProvider[] listProviders(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }
}

///
unittest {
//     auto repo = new IdentityProviderRepository();
//     auto usecase = new ManageIdentityProvidersUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listProviders(tenantId);
//     assert(items !is null);

}
