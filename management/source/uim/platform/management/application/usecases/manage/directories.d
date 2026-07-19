/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.directories;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.directory;
// import uim.platform.management.domain.ports.repositories.directorys;


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
    if (request.accountId.isEmpty)
      return CommandResult(false, "", "Global account ID is required");

    if (request.displayname.isEmpty)
      return CommandResult(false, "", "Display name is required");

    if (directories.existsById(request.tenantId, request.directoryId))
      return CommandResult(false, "", "Directory with the same ID already exists");

    auto directory = Directory(request.tenantId);
    directory.id = request.directoryId.isNull ? DirectoryId(generateId()) : request.directoryId;
    directory.globalAccountId = request.accountId;
    directory.displayName = request.displayName;
    directory.description = request.description;
    directory.features = parseFeatures(request.features);
    directory.manageEntitlements = request.manageEntitlements;
    directory.manageAuthorizations = request.manageAuthorizations;
    directory.labels = request.labels;
    directory.customProperties = request.customProperties;

    writeln("Creating directory: ", directory);

    directories.save(directory);
    return CommandResult(true, directory.id.value, "");
  }

  CommandResult updateDirectory(UpdateDirectoryRequest request) {
    auto directory = directories.findById(request.tenantId, request.directoryId);
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

  Directory getDirectory(TenantId tenantId, DirectoryId id) {
    return directories.findById(tenantId, id);
  }

  Directory[] listDirectories(TenantId tenantId, GlobalAccountId gaId) {
    return directories.findByGlobalAccount(tenantId, gaId);
  }

  Directory[] listDirectories(TenantId tenantId, DirectoryId parentId) {
    return directories.findByParent(tenantId, parentId);
  }

  CommandResult deleteDirectory(TenantId tenantId, DirectoryId id) {
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
