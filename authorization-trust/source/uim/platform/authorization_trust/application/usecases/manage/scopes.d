/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.scopes;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ManageScopesUseCase {
  private ScopeRepository repo;

  this(ScopeRepository repo) {
    this.repo = repo;
  }

  CommandResult createScope(CreateScopeRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Scope name is required");
    if (repo.existsByName(r.name))
      return CommandResult(false, "", "A scope with this name already exists");

    import std.uuid : randomUUID;
    ScopeEntity s;
    s.id          = randomUUID().toString();
    s.name        = r.name;
    s.description = r.description;
    s.appId       = r.appId;
    s.createdAt   = currentTimestamp();
    s.updatedAt   = s.createdAt;

    repo.save(s);
    return CommandResult(true, s.id, "");
  }

  CommandResult updateScope(UpdateScopeRequest r) {
    auto s = repo.findById(r.tenantId, r.scopeId);
    if (s.isNull)
      return CommandResult(false, "", "Scope not found");

    if (r.description.length > 0) s.description = r.description;
    s.updatedAt = currentTimestamp();

    repo.update(s);
    return CommandResult(true, s.id, "");
  }

  CommandResult deleteScope(TenantId tenantId, ScopeId id) {
    auto s = repo.findById(tenantId, id);
    if (s.isNull)
      return CommandResult(false, "", "Scope not found");

    repo.remove(s);
    return CommandResult(true, id, "");
  }

  ScopeEntity getScope(TenantId tenantId, ScopeId id) {
    return repo.findById(tenantId, id);
  }

  ScopeEntity[] listScopes(TenantId tenantId) {
    return repo.findAll(tenantId);
  }
}
