/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.directories;

// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.ports.repositories.directorys;
// import uim.platform.management.domain.types;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage directory hierarchy within global accounts.
class ManageDirectoriesUseCase : UIMUseCase {
  private DirectoryRepository repo;

  this(DirectoryRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDirectoryRequest req) {
    if (req.globalAccountid.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");

    // import std.uuid : randomUUID;

    auto id = randomUUID();

    Directory d;
    d.id = randomUUID();
    d.globalAccountId = req.globalAccountId;
    d.parentDirectoryId = req.parentDirectoryId;
    d.displayName = req.displayName;
    d.description = req.description;
    d.features = parseFeatures(req.features);
    d.manageEntitlements = req.manageEntitlements;
    d.manageAuthorizations = req.manageAuthorizations;
    d.createdBy = req.createdBy;
    d.createdAt = clockSeconds();
    d.modifiedAt = d.createdAt;
    d.labels = req.labels;
    d.customProperties = req.customProperties;

    repo.save(d);
    return CommandResult(true, id.toString, "");
  }

  CommandResult update(DirectoryId id, UpdateDirectoryRequest req) {
    auto d = repo.findById(id);
    if (d.id.isEmpty)
      return CommandResult(false, "", "Directory not found");

    if (req.displayName.length > 0)
      d.displayName = req.displayName;
    if (req.description.length > 0)
      d.description = req.description;
    if (req.labels.length > 0)
      d.labels = req.labels;
    if (req.customProperties.length > 0)
      d.customProperties = req.customProperties;
    d.modifiedAt = clockSeconds();

    repo.update(d);
    return CommandResult(true, id.toString, "");
  }

  Directory getById(DirectoryId id) {
    return repo.findById(id);
  }

  Directory[] listByGlobalAccount(GlobalAccountId gaId) {
    return repo.findByGlobalAccount(gaId);
  }

  Directory[] listByParent(DirectoryId parentId) {
    return repo.findByParent(parentId);
  }

  CommandResult remove(DirectoryId id) {
    auto d = repo.findById(id);
    if (d.id.isEmpty)
      return CommandResult(false, "", "Directory not found");
    if (d.subaccounts.length > 0 || d.subdirectories.length > 0)
      return CommandResult(false, "", "Cannot delete directory with children");
    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  private DirectoryFeature[] parseFeatures(string[] features) {
    DirectoryFeature[] result;
    foreach (f; features) {
      switch (f) {
      case "entitlements":
        result ~= DirectoryFeature.entitlements;
        break;
      case "authorizations":
        result ~= DirectoryFeature.authorizations;
        break;
      default:
        result ~= DirectoryFeature.default_;
        break;
      }
    }
    return result;
  }
}
