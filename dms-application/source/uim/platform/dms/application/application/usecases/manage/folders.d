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
  private IFolderRepository folders;
  private IRepositoryRepository repoRepo;

  this(IFolderRepository folders, IRepositoryRepository repoRepo) {
    this.folders = folders;
    this.repoRepo = repoRepo;
  }

  CommandResult createFolder(CreateFolderRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Folder name is required");
    if (r.repositoryId.isEmpty)
      return CommandResult(false, "", "Repository ID is required");

    // Validate repository exists
    auto repository = repoRepo.findById(r.tenantId, r.repositoryId);
    if (repository.isNull)
      return CommandResult(false, "", "Repository not found");

    // Build path
    string path = "/" ~ r.name;
    if (r.parentFolderId.value.length > 0) {
      auto parent = folders.findById(r.tenantId, r.parentFolderId);
      if (parent.isNull)
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

    folders.save(entity);
    return CommandResult(true, entity.id.value(), "");
  }

  Folder[] listFolders(TenantId tenantId) {
    return folders.findByTenant(tenantId);
  }

  Folder[] listByRepository(TenantId tenantId, RepositoryId repositoryId) {
    return folders.findByRepository(tenantId, repositoryId);
  }

  Folder[] listChildren(TenantId tenantId, FolderId parentFolderId) {
    return folders.findByParent(tenantId, parentFolderId);
  }

  Folder getFolder(TenantId tenantId, FolderId id) {
    return folders.findById(tenantId, id);
  }

  CommandResult updateFolder(UpdateFolderRequest r) {
    if (!folders.existsById(r.tenantId, r.id))
      return CommandResult(false, "", "Folder not found");

    auto entity = folders.findById(r.tenantId, r.id);
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

    folders.update(entity);
    return CommandResult(true, entity.id.value(), "");
  }

  CommandResult moveFolder(MoveFolderRequest r) {
    if (!folders.existsById(r.tenantId, r.id))
      return CommandResult(false, "", "Folder not found");

    auto entity = folders.findById(r.tenantId, r.id);
    if (r.newParentFolderId.value.length > 0) {
      auto newParent = folders.findById(r.tenantId, r.newParentFolderId);
      if (newParent.isNull)
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

    folders.update(entity);
    return CommandResult(true, entity.id.value(), "");
  }

  CommandResult deleteFolder(TenantId tenantId, FolderId id) {
    if (!folders.existsById(tenantId, id))
      return CommandResult(false, "", "Folder not found");

    folders.removeById(tenantId, id);
    return CommandResult(true, id.value(), "");
  }
}
