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

  CommandResult createDirectory(CreateDirectoryRequest request) {
    if (request.globalAccountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");
    if (request.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");

    Directory directory = Directory.createFromRequest(request);
    directories.save(directory);
    return CommandResult(true, directory.id.value, "");
  }

  CommandResult updateDirectory(DirectoryId id, UpdateDirectoryRequest request) {
    auto directory = directories.findById(tenantId, id);
    if (directory.isNull)
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
    return CommandResult(true, directory.id.value, "");
  }

  Directory getDirectoryById(DirectoryId id) {
    return directories.findById(tenantId, id);
  }

  Directory[] listDirectoriesByGlobalAccount(GlobalAccountId gaId) {
    return directories.findByGlobalAccount(gaId);
  }

  Directory[] listDirectories(DirectoryId parentId) {
    return directories.findByParent(parentId);
  }

  CommandResult deleteDirectory(DirectoryId id) {
    auto directory = directories.findById(tenantId, id);
    if (directory.isNull)
      return CommandResult(false, "", "Directory not found");

    if (directory.subaccounts.length > 0 || directory.subdirectories.length > 0)
      return CommandResult(false, "", "Cannot delete directory with children");

    directories.remove(directory);
    return CommandResult(true, directory.id.value, "");
  }

  private DirectoryFeature[] parseFeatures(string[] features) {
    return features.map!(f => f.to!DirectoryFeature).array;
  }

}
