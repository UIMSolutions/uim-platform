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
class ManageDirectoriesUseCase { // TODO: UIMUseCase {
  private DirectoryRepository directories;

  this(DirectoryRepository directories) {
    this.directories = directories;
  }

  CommandResult create(CreateDirectoryRequest request) {
    if (request.globalAccountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (request.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");

    Directory directory = Directory.createFromRequest(request);
    directories.save(directory);
    return CommandResult(true, directory.id.toString, "");
  }

  CommandResult update(string id, UpdateDirectoryRequest request) {
    return update(DirectoryId(id), request);
  }

  CommandResult update(DirectoryId id, UpdateDirectoryRequest request) {
    auto directory = directories.findById(id);
    if (directory.id.isEmpty)
      return CommandResult(false, "", "Directory not found");

    if (request.displayName.length > 0)
      directory.displayName = request.displayName;
    if (request.description.length > 0)
      directory.description = request.description;
    if (request.labels.length > 0)
      directory.labels = request.labels;
    if (request.customProperties.length > 0)
      directory.customProperties = request.customProperties;
    directory.updatedAt = clockSeconds();

    directories.update(directory);
    return CommandResult(true, directory.id.toString, "");
  }

  Directory getById(string id) {
    return directories.findById(DirectoryId(id));
  }

  Directory getById(DirectoryId id) {
    return directories.findById(id);
  }

  Directory[] listByGlobalAccount(string gaId) {
    return listByGlobalAccount(GlobalAccountId(gaId));
  }

  Directory[] listByGlobalAccount(GlobalAccountId gaId) {
    return directories.findByGlobalAccount(gaId);
  }

  Directory[] listByParent(string parentId) {
    return directories.findByParent(DirectoryId(parentId));
  }

  Directory[] listByParent(DirectoryId parentId) {
    return directories.findByParent(parentId);
  }

  CommandResult remove(string id) {
    return remove(DirectoryId(id));
  }

  CommandResult remove(DirectoryId id) {
    auto directory = directories.findById(id);
    if (directory.id.isEmpty)
      return CommandResult(false, "", "Directory not found");
    if (directory.subaccounts.length > 0 || directory.subdirectories.length > 0)
      return CommandResult(false, "", "Cannot delete directory with children");
    directories.removeById(id);
    return CommandResult(true, directory.id.toString, "");
  }

  private DirectoryFeature[] parseFeatures(string[] features) {
    return features.map!(f => f.to!DirectoryFeature).array;
  }

}
