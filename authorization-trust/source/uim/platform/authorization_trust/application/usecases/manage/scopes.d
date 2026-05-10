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

  CommandResult create(CreateScopeRequest r) {
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

  CommandResult update(UpdateScopeRequest r) {
    auto s = repo.findById(r.id);
    if (s.id.length == 0)
      return CommandResult(false, "", "Scope not found");

    if (r.description.length > 0) s.description = r.description;
    s.updatedAt = currentTimestamp();

    repo.update(s);
    return CommandResult(true, s.id, "");
  }

  CommandResult remove(ScopeId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Scope not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  ScopeEntity getById(ScopeId id) {
    return repo.findById(id);
  }

  ScopeEntity[] listAll() {
    return repo.findAll();
  }
}
