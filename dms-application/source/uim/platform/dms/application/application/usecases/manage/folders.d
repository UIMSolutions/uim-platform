/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.manage.folders;

// // import std.datetime.systime : Clock;
// // import std.uuid : randomUUID;
// 
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.ports.repositories.folders;
// import uim.platform.dms.application.domain.ports.repositoriess;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
class ManageFoldersUseCase { // TODO: UIMUseCase {
  private IFolderRepository folderRepo;
  private IRepositoryRepository repoRepo;

  this(IFolderRepository folderRepo, IRepositoryRepository repoRepo) {
    this.folderRepo = folderRepo;
    this.repoRepo = repoRepo;
  }

  CommandResult createFolder(CreateFolderRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Folder name is required");
    if (r.repositoryId.isEmpty)
      return CommandResult(false, "", "Repository ID is required");

    // Validate repository exists
    auto repository = repoRepo.findById(r.repositoryId, r.tenantId);
    if (repository is null)
      return CommandResult(false, "", "Repository not found");

    // Build path
    string path = "/" ~ r.name;
    if (r.parentFolderId.value.length > 0) {
      auto parent = folderRepo.findById(r.parentFolderId, r.tenantId);
      if (parent is null)
        return CommandResult(false, "", "Parent folder not found");
      path = parent.path ~ "/" ~ r.name;
    }

    auto entity = new Folder();
    entity.id = randomUUID();
    entity.tenantId = r.tenantId;
    entity.repositoryId = r.repositoryId;
    entity.parentFolderId = r.parentFolderId;
    entity.name = r.name;
    entity.description = r.description;
    entity.path = path;
    entity.createdBy = r.createdBy;
    entity.createdAt = Clock.currStdTime();
    entity.updatedAt = entity.createdAt;

    folderRepo.save(entity);
    return CommandResult(entity.id, "");
  }

  Folder[] listFolders(TenantId tenantId) {
    return folderRepo.findByTenant(tenantId);
  }

  Folder[] listByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return folderRepo.findByRepository(tenantId, repositoryId);
  }

  Folder[] listChildren(TenantId tenantId, FolderId parentFolderId) {
    return folderRepo.findByParent(tenantId, parentFolderId);
  }

  Folder getFolder(TenantId tenantId, FolderId id) {
    return folderRepo.findById(tenantId, id);
  }

  CommandResult updateFolder(UpdateFolderRequest r) {
    auto entity = folderRepo.findById(r.id, r.tenantId);
    if (entity is null)
      return CommandResult(false, "", "Folder not found");

    if (r.name.length > 0) {
      entity.name = r.name;
      // Update path
      auto lastSlash = lastIndexOf(entity.path, '/');
      if (lastSlash >= 0)
        entity.path = entity.path[0 .. cast(size_t)(lastSlash + 1)] ~ r.name;
      else
        entity.path = "/" ~ r.name;
    }
    if (r.description.length > 0)
      entity.description = r.description;
    entity.updatedAt = Clock.currStdTime();

    folderRepo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult moveFolder(MoveFolderRequest r) {
    auto entity = folderRepo.findById(r.id, r.tenantId);
    if (entity is null)
      return CommandResult(false, "", "Folder not found");

    if (r.newParentFolderId.length > 0) {
      auto newParent = folderRepo.findById(r.newParentFolderId, r.tenantId);
      if (newParent is null)
        return CommandResult(false, "", "New parent folder not found");
      entity.parentFolderId = r.newParentFolderId;
      entity.path = newParent.path ~ "/" ~ entity.name;
    }
    else
    {
      entity.parentFolderId = "";
      entity.path = "/" ~ entity.name;
    }
    entity.updatedAt = Clock.currStdTime();

    folderRepo.update(entity);
    return CommandResult(entity.id, "");
  }

  CommandResult deleteFolder(TenantId tenantId, FolderId id) {
    auto entity = folderRepo.findById(tenantId, id);
    if (entity is null)
      return CommandResult(false, "", "Folder not found");

    folderRepo.remove(tenantId, id);
    return CommandResult(true, id.toString(), "");
  }

  private static long lastIndexOf(string s, char c) {
    for (long i = s.length - 1; i >= 0; --i)
      if (s[cast(size_t) i] == c)
        return i;
    return -1;
  }
}
