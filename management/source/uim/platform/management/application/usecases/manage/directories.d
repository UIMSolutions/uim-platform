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
    if (req.globalAccountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");

    Directory directory;
    directory.id = randomUUID();
    directory.globalAccountId = req.globalAccountId;
    directory.parentDirectoryId = req.parentDirectoryId;
    directory.displayName = req.displayName;
    directory.description = req.description;
    directory.features = parseFeatures(req.features);
    directory.manageEntitlements = req.manageEntitlements;
    directory.manageAuthorizations = req.manageAuthorizations;
    directory.createdBy = req.createdBy;
    directory.createdAt = clockSeconds();
    directory.modifiedAt = directory.createdAt;
    directory.labels = req.labels;
    directory.customProperties = req.customProperties;

    repo.save(directory);
    return CommandResult(true, directory.id.toString, "");
  }

  CommandResult update(DirectoryId id, UpdateDirectoryRequest req) {
    auto directory = repo.findById(id);
    if (directory.id.isEmpty)
      return CommandResult(false, "", "Directory not found");

    if (req.displayName.length > 0)
      directory.displayName = req.displayName;
    if (req.description.length > 0)
      directory.description = req.description;
    if (req.labels.length > 0)
      directory.labels = req.labels;
    if (req.customProperties.length > 0)
      directory.customProperties = req.customProperties;
    directory.modifiedAt = clockSeconds();

    repo.update(directory);
    return CommandResult(true, directory.id.toString, "");
  }

  Directory getById(string id) {
    return repo.findById(DirectoryId(id));
  }

  Directory getById(DirectoryId id) {
    return repo.findById(id);
  }

  Directory[] listByGlobalAccount(GlobalAccountId gaId) {
    return repo.findByGlobalAccount(gaId);
  }

  Directory[] listByParent(string parentId) {
    return repo.findByParent(DirectoryId(parentId));
  }

  Directory[] listByParent(DirectoryId parentId) {
    return repo.findByParent(parentId);
  }

  CommandResult remove(string id) {
    return remove(DirectoryId(id));
  }

  CommandResult remove(DirectoryId id) {
    auto directory = repo.findById(id);
    if (directory.id.isEmpty)
      return CommandResult(false, "", "Directory not found");
    if (directory.subaccounts.length > 0 || directory.subdirectories.length > 0)
      return CommandResult(false, "", "Cannot delete directory with children");
    repo.remove(id);
    return CommandResult(true, directory.id.toString, "");
  }

  private DirectoryFeature[] parseFeatures(string[] features) {
    return features.map!(f => parseFeature(f)).array;
  }

  private DirectoryFeature parseFeature(string feature) {
    switch (feature) {
    case "entitlements":
      return DirectoryFeature.entitlements;
    case "authorizations":
      return DirectoryFeature.authorizations;
    }
    return DirectoryFeature.default_;
  }
}
