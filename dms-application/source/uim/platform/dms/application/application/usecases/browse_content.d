/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.application.usecases.browse_content;

// // import std.datetime.systime : Clock;
// // import std.uuid : randomUUID;
// 
// import uim.platform.dms.application.application.dto;
// import uim.platform.dms.application.domain.entities.document;
// import uim.platform.dms.application.domain.entities.folder;
// import uim.platform.dms.application.domain.entities.favorite;
// import uim.platform.dms.application.domain.ports.repositories.documents;
// import uim.platform.dms.application.domain.ports.repositories.folders;
// import uim.platform.dms.application.domain.ports.repositories.favorites;
// import uim.platform.dms.application.domain.ports.repositories.repositorys;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
/// Browsing summary for a repository.
struct RepositorySummary {
  string repositoryId;
  string name;
  long totalDocuments;
  long totalFolders;
  RepositoryStatus status;
}

/// Use case for browsing content, searching, and managing favorites.
class BrowseContentUseCase : UIMUseCase {
  private IDocumentRepository docRepo;
  private IFolderRepository folderRepo;
  private IFavoriteRepository favRepo;
  private IRepositoryRepository repoRepo;

  this(IDocumentRepository docRepo, IFolderRepository folderRepo,
      IFavoriteRepository favRepo, IRepositoryRepository repoRepo) {
    this.docRepo = docRepo;
    this.folderRepo = folderRepo;
    this.favRepo = favRepo;
    this.repoRepo = repoRepo;
  }

  /// Search documents by name.
  Document[] searchDocuments(string query, TenantId tenantId) {
    return docRepo.findByName(query, tenantId);
  }

  /// Browse folder contents (subfolders + documents).
  FolderContents browseFolderContents(FolderId folderId, TenantId tenantId) {
    FolderContents result;
    result.subfolders = folderRepo.findByParent(folderId, tenantId);
    result.documents = docRepo.findByFolder(folderId, tenantId);
    return result;
  }

  /// Get repository summary.
  RepositorySummary getRepositorySummary(string repositoryId, TenantId tenantId) {
    RepositorySummary summary;
    auto repo = repoRepo.findById(repositoryId, tenantId);
    if (repo is null)
      return summary;

    summary.repositoryId = repositoryId;
    summary.name = repo.name;
    summary.totalDocuments = docRepo.countByRepository(repositoryId, tenantId);
    summary.totalFolders = cast(long) folderRepo.findByRepository(repositoryId, tenantId).length;
    summary.status = repo.status;
    return summary;
  }

  /// Add a favorite.
  CommandResult addFavorite(CreateFavoriteRequest r) {
    // Check for duplicate
    auto existing = favRepo.findByUserAndResource(r.userId, r.resourceId, r.tenantId);
    if (existing !is null)
      return CommandResult(existing.id, "");

    auto fav = new Favorite();
    fav.id = randomUUID();
    fav.tenantId = r.tenantId;
    fav.userId = r.userId;
    fav.resourceId = r.resourceId;
    fav.resourceType = r.resourceType;
    fav.createdAt = Clock.currStdTime();

    favRepo.save(fav);
    return CommandResult(fav.id, "");
  }

  /// Get user favorites.
  Favorite[] getFavorites(UserId userId, TenantId tenantId) {
    return favRepo.findByUser(userId, tenantId);
  }

  /// Remove a favorite.
  CommandResult removeFavorite(FavoriteId id, TenantId tenantId) {
    auto fav = favRepo.findById(id, tenantId);
    if (fav is null)
      return CommandResult("", "Favorite not found");

    favRepo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}

struct FolderContents {
  Folder[] subfolders;
  Document[] documents;
}
