module application.usecases.manage_folders;

import std.datetime.systime : Clock;
import std.uuid : randomUUID;

import  uim.platform.dms_application.application.dto;
import  uim.platform.dms_application.domain.entities.folder;
import  uim.platform.dms_application.domain.ports.folder_repository;
import  uim.platform.dms_application.domain.ports.repository_repository;
import  uim.platform.dms_application.domain.types;

class ManageFoldersUseCase
{
  private IFolderRepository folderRepo;
  private IRepositoryRepository repoRepo;

  this(IFolderRepository folderRepo, IRepositoryRepository repoRepo)
  {
    this.folderRepo = folderRepo;
    this.repoRepo = repoRepo;
  }

  CommandResult createFolder(CreateFolderRequest r)
  {
    if (r.name.length == 0)
      return CommandResult("", "Folder name is required");
    if (r.repositoryId.length == 0)
      return CommandResult("", "Repository ID is required");

    // Validate repository exists
    auto repository = repoRepo.findById(r.repositoryId, r.tenantId);
    if (repository is null)
      return CommandResult("", "Repository not found");

    // Build path
    string path = "/" ~ r.name;
    if (r.parentFolderId.length > 0)
    {
      auto parent = folderRepo.findById(r.parentFolderId, r.tenantId);
      if (parent is null)
        return CommandResult("", "Parent folder not found");
      path = parent.path ~ "/" ~ r.name;
    }

    auto entity = new Folder();
    entity.id = randomUUID().toString();
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

  Folder[] listFolders(TenantId tenantId)
  {
    return folderRepo.findByTenant(tenantId);
  }

  Folder[] listByRepository(RepositoryId repositoryId, TenantId tenantId)
  {
    return folderRepo.findByRepository(repositoryId, tenantId);
  }

  Folder[] listChildren(FolderId parentId, TenantId tenantId)
  {
    return folderRepo.findByParent(parentId, tenantId);
  }

  Folder getFolder(FolderId id, TenantId tenantId)
  {
    return folderRepo.findById(id, tenantId);
  }

  CommandResult updateFolder(UpdateFolderRequest r)
  {
    auto entity = folderRepo.findById(r.id, r.tenantId);
    if (entity is null)
      return CommandResult("", "Folder not found");

    if (r.name.length > 0)
    {
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

  CommandResult moveFolder(MoveFolderRequest r)
  {
    auto entity = folderRepo.findById(r.id, r.tenantId);
    if (entity is null)
      return CommandResult("", "Folder not found");

    if (r.newParentFolderId.length > 0)
    {
      auto newParent = folderRepo.findById(r.newParentFolderId, r.tenantId);
      if (newParent is null)
        return CommandResult("", "New parent folder not found");
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

  CommandResult deleteFolder(FolderId id, TenantId tenantId)
  {
    auto entity = folderRepo.findById(id, tenantId);
    if (entity is null)
      return CommandResult("", "Folder not found");

    folderRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }

  private static long lastIndexOf(string s, char c)
  {
    for (long i = cast(long) s.length - 1; i >= 0; --i)
      if (s[cast(size_t) i] == c)
        return i;
    return -1;
  }
}
