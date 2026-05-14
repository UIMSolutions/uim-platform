/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.identity_providers;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ManageIdentityProvidersUseCase {
  private IdentityProviderRepository repo;

  this(IdentityProviderRepository repo) {
    this.repo = repo;
  }

  CommandResult createIdentityProvider(CreateIdentityProviderRequest r) {
    if (r.alias_.length == 0)
      return CommandResult(false, "", "IdP alias is required");
    if (repo.existsByAlias(r.alias_))
      return CommandResult(false, "", "An identity provider with this alias already exists");

    import std.uuid : randomUUID;
    IdentityProviderEntity idp;
    idp.id          = randomUUID().toString();
    idp.alias_      = r.alias_;
    idp.displayName = r.displayName;
    idp.idpType     = parseIdpType(r.idpType);
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
    return CommandResult(true, idp.id, "");
  }

  CommandResult updateIdentityProvider(UpdateIdentityProviderRequest r) {
    auto idp = repo.findById(r.tenantId, r.id);
    if (idp.id.length == 0)
      return CommandResult(false, "", "Identity provider not found");

    if (r.displayName.length > 0) idp.displayName = r.displayName;
    if (r.metadataUrl.length > 0) idp.metadataUrl = r.metadataUrl;
    if (r.ssoUrl.length > 0)      idp.ssoUrl      = r.ssoUrl;
    if (r.sloUrl.length > 0)      idp.sloUrl      = r.sloUrl;
    if (r.signingCert.length > 0) idp.signingCert = r.signingCert;
    idp.isActive  = r.isActive;
    idp.isDefault = r.isDefault;
    idp.updatedAt = currentTimestamp();

    repo.update(idp);
    return CommandResult(true, idp.id.value, "");
  }

  CommandResult deleteIdentityProviderv(TenantId tenantId, IdentityProviderId id) {
    auto provider = repo.findById(tenantId, id);
    if (provider.isNull)
      return CommandResult(false, "", "Identity provider not found");
      
    repo.remove(provider);
    return CommandResult(true, provider.id.value, "");
  }

  IdentityProviderEntity getIdentityProvider(TenantId tenantId, IdentityProviderId id) {
    return repo.findById(tenantId, id);
  }

  IdentityProviderEntity[] listIdentityProviders(TenantId tenantId) {
    return repo.findAll(tenantId);
  }
}
