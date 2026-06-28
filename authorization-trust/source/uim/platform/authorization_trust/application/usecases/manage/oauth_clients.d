/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.oauth_clients;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class ManageOAuthClientsUseCase {
  private OAuthClientRepository repo;

  this(OAuthClientRepository repo) {
    this.repo = repo;
  }

  CommandResult createOAuthClient(CreateOAuthClientRequest r) {
    if (r.clientId.isEmpty)
      return CommandResult(false, "", "clientId is required");

    auto existingClients = repo.findByTenant(r.tenantId).filter!(c => c.clientId == r.clientId).array;
    if (!existingClients.empty)
      return CommandResult(false, "", "A client with this clientId already exists");

    import std.uuid : randomUUID;
    OAuthClient c;
    c.id          = randomUUID().toString();
    c.tenantId    = r.tenantId;
    c.clientId    = r.clientId;
    c.clientSecret = r.clientSecret.length > 0 ? TokenService.hashSecret(r.clientSecret) : "";
    c.name        = r.name;
    c.description = r.description;
    foreach (gt; r.grantTypes)
      c.grantTypes ~= gt.toGrantType;
    c.scopes       = r.scopes.dup;
    c.redirectUris = r.redirectUris.dup;
    c.clientType   = r.clientType.toClientType;
    c.appId        = r.appId;
    c.createdAt    = currentTimestamp();
    c.updatedAt    = c.createdAt;

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  CommandResult updateClient(UpdateOAuthClientRequest r) {
    auto c = repo.find(r.tenantId, r.clientId);
    if (c.isNull)
      return CommandResult(false, "", "OAuth client not found");

    if (r.name.length > 0)       c.name = r.name;
    if (r.description.length > 0) c.description = r.description;
    if (r.scopes.length > 0)     c.scopes = r.scopes.dup;
    if (r.redirectUris.length > 0) c.redirectUris = r.redirectUris.dup;
    if (r.grantTypes.length > 0) {
      c.grantTypes = r.grantTypes.map!(gt => gt.toGrantType).array;
    }
    c.updatedAt = currentTimestamp();

    repo.update(c);
    return CommandResult(true, c.id.value, "");
  }

  CommandResult deleteClient(TenantId tenantId, OAuthClientId id) {
    auto c = repo.find(tenantId, id);
    if (c.isNull)
      return CommandResult(false, "", "OAuth client not found");

    repo.remove(c);
    return CommandResult(true, id.value, "");
  }

  OAuthClient getClient(TenantId tenantId, OAuthClientId id) {
    return repo.find(tenantId, id);
  }

  OAuthClient[] listClients(TenantId tenantId) {
    return repo.find(tenantId);
  }

  OAuthClient[] listClients(TenantId tenantId, string appId) {
    return repo.findByApp(tenantId, appId);
  }
}
