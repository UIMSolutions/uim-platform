/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.application.usecases.manage.role_collections;

import uim.platform.authorization_trust;

// mixin(ShowModule!());

@safe:

class ManageRoleCollectionsUseCase {
  private RoleCollectionRepository repo;

  this(RoleCollectionRepository repo) {
    this.repo = repo;
  }

  CommandResult createRoleCollection(CreateRoleCollectionRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Role collection name is required");
    if (repo.existsByName(r.tenantId, r.name))
      return CommandResult(false, "", "A role collection with this name already exists");

    import std.uuid : randomUUID;

    RoleCollectionEntity rc;
    rc.initEntity(r.tenantId);
    rc.name = r.name;
    rc.description = r.description;
    rc.roleReferences = r.roleReferences.dup;

    repo.save(rc);
    return CommandResult(true, rc.id.value, "");
  }

  CommandResult updateRoleCollection(UpdateRoleCollectionRequest r) {
    auto rc = repo.find(r.tenantId, r.collectionId);
    if (rc.isNull)
      return CommandResult(false, "", "Role collection not found");

    if (r.description.length > 0)
      rc.description = r.description;
    if (r.roleReferences.length > 0)
      rc.roleReferences = r.roleReferences.dup;
    rc.updatedAt = currentTimestamp();

    repo.update(rc);
    return CommandResult(true, rc.id.value, "");
  }

  CommandResult deleteRoleCollection(TenantId tenantId, RoleCollectionId id) {
    auto rc = repo.findById(tenantId, id);
    if (rc.isNull)
      return CommandResult(false, "", "Role collection not found");

    repo.remove(rc);
    return CommandResult(true, rc.id.value, "");
  }

  RoleCollectionEntity getRoleCollection(TenantId tenantId, RoleCollectionId id) {
    return repo.findById(tenantId, id);
  }

  RoleCollectionEntity[] listRoleCollections(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }
}
