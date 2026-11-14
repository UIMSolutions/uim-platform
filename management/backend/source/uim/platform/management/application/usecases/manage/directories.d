/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.application.usecases.manage.directories;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Use case: manage directory hierarchy within global accounts.
class ManageDirectoriesUseCase : IManageDirectoriesUseCase {
  /// Maximum nesting depth of directories (SAP BTP allows 5 levels).
  enum maxDepth = 5;

  protected IDirectoryRepository directories;
  protected IGlobalAccountRepository globalAccounts;
  protected ISubaccountRepository subaccounts;
  protected PlatformEventRecorder recorder;

  this(IDirectoryRepository directories, IGlobalAccountRepository globalAccounts,
      ISubaccountRepository subaccounts, PlatformEventRecorder recorder) {
    this.directories = directories;
    this.globalAccounts = globalAccounts;
    this.subaccounts = subaccounts;
    this.recorder = recorder;
  }

  UsecaseResult createDirectory(CreateDirectoryRequest request) {
    if (request.accountId.isEmpty)
      return invalid("Global account ID is required");
    if (request.displayName.length == 0)
      return invalid("Display name is required");
    if (!request.directoryId.isEmpty && directories.existsById(request.tenantId, request.directoryId))
      return conflict("Directory '" ~ request.directoryId.value ~ "' already exists");

    auto ga = globalAccounts.findById(request.tenantId, request.accountId);
    if (ga.isNull)
      return notFound("Global account");
    if (!ga.isActive)
      return violation("Global account '" ~ ga.displayName ~ "' is " ~ enumName(ga.status));

    if (!request.parentDirectoryId.isEmpty) {
      auto parent = directories.findById(request.tenantId, request.parentDirectoryId);
      if (parent.isNull)
        return notFound("Parent directory");
      if (parent.globalAccountId != request.accountId)
        return violation("Parent directory belongs to another global account");
      if (depthOf(parent) + 1 >= maxDepth)
        return violation("Directories can be nested at most " ~ maxDepth.to!string ~ " levels deep");
    }

    return guarded(() {
      ga.ensureDirectoryCapacity(directories.findByGlobalAccount(request.tenantId, ga.id).length);

      auto directory = AccountDirectory(request.tenantId);
      if (!request.directoryId.isEmpty)
        directory.id = request.directoryId;
      directory.globalAccountId = request.accountId;
      directory.parentDirectoryId = request.parentDirectoryId;
      directory.displayName = request.displayName;
      directory.description = request.description;
      foreach (f; request.features) {
        DirectoryFeature feature;
        if (tryParseEnum!DirectoryFeature(f, feature) && !directory.features.canFind(feature))
          directory.features ~= feature;
      }
      directory.manageEntitlements = request.manageEntitlements || directory.features.canFind(DirectoryFeature.entitlements);
      directory.manageAuthorizations = request.manageAuthorizations || directory.features.canFind(DirectoryFeature.authorizations);
      directory.labels = request.labels;
      directory.customProperties = request.customProperties;
      directory.createdBy = actor(request.createdBy);
      directory.updatedBy = directory.createdBy;

      directories.save(directory);
      recorder.record(request.tenantId, PlatformEventRecorder.ofDirectory(directory),
        EnvironmentEventCategory.directoryChange, "directory.created",
        "Directory created: " ~ directory.displayName, directory.createdBy);
      return created(directory.id.value, "Directory created");
    });
  }

  UsecaseResult updateDirectory(UpdateDirectoryRequest request) {
    auto directory = directories.findById(request.tenantId, request.directoryId);
    if (directory.isNull)
      return notFound("Directory");

    if (request.displayName.length > 0)
      directory.displayName = request.displayName;
    if (request.description.length > 0)
      directory.description = request.description;
    if (request.labels.length > 0)
      directory.labels = request.labels;
    if (request.customProperties.length > 0)
      directory.customProperties = request.customProperties;
    directory.update();

    directories.update(directory);
    recorder.record(request.tenantId, PlatformEventRecorder.ofDirectory(directory),
      EnvironmentEventCategory.directoryChange, "directory.updated",
      "Directory updated: " ~ directory.displayName, directory.updatedBy);
    return ok(directory.id.value, "Directory updated");
  }

  AccountDirectory getDirectory(TenantId tenantId, DirectoryId id) {
    return directories.findById(tenantId, id);
  }

  AccountDirectory[] listDirectories(TenantId tenantId) {
    return directories.findByTenant(tenantId);
  }

  AccountDirectory[] listDirectories(TenantId tenantId, GlobalAccountId gaId) {
    return directories.findByGlobalAccount(tenantId, gaId);
  }

  AccountDirectory[] listDirectories(TenantId tenantId, DirectoryId parentId) {
    return directories.findByParent(tenantId, parentId);
  }

  UsecaseResult deleteDirectory(TenantId tenantId, DirectoryId id) {
    auto directory = directories.findById(tenantId, id);
    if (directory.isNull)
      return notFound("Directory");

    // The hierarchy is derived from the children, so it can never be stale.
    if (subaccounts.findByDirectory(tenantId, id).length > 0 || directories.findByParent(tenantId, id).length > 0)
      return violation("Cannot delete directory '" ~ directory.displayName ~ "' with subdirectories or subaccounts");

    directories.remove(directory);
    recorder.record(tenantId, PlatformEventRecorder.ofDirectory(directory),
      EnvironmentEventCategory.directoryChange, "directory.deleted",
      "Directory deleted: " ~ directory.displayName, UserId("system"));
    return ok(directory.id.value, "Directory deleted");
  }

  /// Nesting depth of a directory (root-level = 0). Stops on cycles.
  protected size_t depthOf(AccountDirectory directory) {
    size_t depth;
    auto current = directory;
    while (!current.parentDirectoryId.isEmpty && depth <= maxDepth) {
      current = directories.findById(current.tenantId, current.parentDirectoryId);
      if (current.isNull)
        break;
      depth++;
    }
    return depth;
  }
}
