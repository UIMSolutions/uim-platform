/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.oauth.application.usecases.manage_scopes;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ManageScopesUseCase : IManageScopes {
  protected OAuthRepositories repos;

  this(OAuthRepositories repos) {
    this.repos = repos;
  }

  OAuthScope[] listScopes(TenantId tenantId) {
    return repos.scopes.findAll(tenantId);
  }

  OAuthScope getScope(TenantId tenantId, OAuthScopeId id) {
    return repos.scopes.findById(tenantId, id).required("Scope '" ~ id.value ~ "'");
  }

  OAuthScope createScope(CreateScopeRequest r) {
    OAuthScope s;
    stampCreated!(OAuthScope, OAuthScopeId)(s, r.tenantId, r.actor, r.id);
    if (repos.scopes.existsById(r.tenantId, s.id))
      throw OAuthException.conflict("Scope '" ~ s.id.value ~ "' already exists");
    s.applicationId = r.applicationId.strip;
    s.name = r.name.strip;
    s.description = r.description;
    s.validate();
    if (!repos.scopes.findByName(r.tenantId, s.name).isNull)
      throw OAuthException.conflict("A scope named '" ~ s.name ~ "' already exists");
    repos.scopes.save(s);
    return s;
  }

  OAuthScope updateScope(UpdateScopeRequest r) {
    auto s = getScope(r.tenantId, r.id);
    if (r.applicationId.isSet)
      s.applicationId = r.applicationId.value.strip;
    r.description.applyTo(s.description);
    applyEnum(r.status, s.status, "status");
    s.validate();
    stampUpdated(s, r.actor);
    repos.scopes.save(s);
    return s;
  }

  void deleteScope(TenantId tenantId, OAuthScopeId id) {
    auto s = getScope(tenantId, id);
    auto users = repos.clients.findAll(tenantId).filter!(c => c.allowedScopes.canFind(s.name)).map!(c => c.clientId).array;
    if (users.length > 0)
      throw OAuthException.ruleViolation("Scope '" ~ s.name ~ "' is still allowed for " ~ countOf(users.length, "client")
          ~ ": " ~ users.join(", "));
    repos.scopes.removeById(tenantId, id);
  }
}
