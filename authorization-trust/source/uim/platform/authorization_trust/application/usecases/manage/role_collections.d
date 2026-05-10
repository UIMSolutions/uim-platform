/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.role_collections;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class ManageRoleCollectionsUseCase {
  private RoleCollectionRepository repo;

  this(RoleCollectionRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateRoleCollectionRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Role collection name is required");
    if (repo.existsByName(r.name))
      return CommandResult(false, "", "A role collection with this name already exists");

    import std.uuid : randomUUID;
    RoleCollectionEntity rc;
    rc.id             = randomUUID().toString();
    rc.name           = r.name;
    rc.description    = r.description;
    rc.roleReferences = r.roleReferences.dup;
    rc.createdAt      = currentTimestamp();
    rc.updatedAt      = rc.createdAt;

    repo.save(rc);
    return CommandResult(true, rc.id, "");
  }

  CommandResult update(UpdateRoleCollectionRequest r) {
    auto rc = repo.findById(r.id);
    if (rc.id.length == 0)
      return CommandResult(false, "", "Role collection not found");

    if (r.description.length > 0)    rc.description = r.description;
    if (r.roleReferences.length > 0) rc.roleReferences = r.roleReferences.dup;
    rc.updatedAt = currentTimestamp();

    repo.update(rc);
    return CommandResult(true, rc.id, "");
  }

  CommandResult remove(RoleCollectionId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Role collection not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  RoleCollectionEntity getById(RoleCollectionId id) {
    return repo.findById(id);
  }

  RoleCollectionEntity[] listAll() {
    return repo.findAll();
  }
}
