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
// import uim.platform.dms.application.domain.ports.repositoriess;
// import uim.platform.dms.application.domain.types;

import uim.platform.dms.application;

mixin(ShowModule!());
@safe:
/// Browsing summary for a repository.
struct RepositorySummary {
  RepositoryId repositoryId;
  string name;
  long totalDocuments;
  long totalFolders;
  RepositoryStatus status;
}

/// Use case for browsing content, searching, and managing favorites.
class BrowseContentUseCase { // TODO: UIMUseCase {
  private IDocumentRepository docs;
  private IFolderRepository folders;
  private IFavoriteRepository favorites;
  private IRepositoryRepository repositories;

  this(IDocumentRepository docs, IFolderRepository folders,
      IFavoriteRepository favorites, IRepositoryRepository repositories) {
    this.docs = docs;
    this.folders = folders;
    this.favorites = favorites;
    this.repositories = repositories;
  }

  /// Search documents by name.
  Document[] searchDocuments(TenantId tenantId, string query) {
    return docs.findByName(tenantId, query);
  }

  /// Browse folder contents (subfolders + documents).
  FolderContents browseFolderContents(TenantId tenantId, FolderId folderId) {
    FolderContents result;
    result.subfolders = folders.findByParent(tenantId, folderId);
    result.documents = docs.findByFolder(tenantId, folderId);
    return result;
  }

  /// Get repository summary.
  RepositorySummary getRepositorySummary(TenantId tenantId, RepositoryId repositoryId) {
    auto repo = repositories.findById(tenantId, repositoryId);
    RepositorySummary summary;
    if (repo.isNull)
      return summary;

    summary.repositoryId = repo.id;
    summary.name = repo.name;
    summary.totalDocuments = docs.countByRepository(tenantId, repositoryId);
    summary.totalFolders = folders.countByRepository(tenantId, repositoryId);
    summary.status = repo.status;
    return summary;
  }

  /// Add a favorite.
  CommandResult addFavorite(CreateFavoriteRequest r) {
    // Check for duplicate
    auto fav = favorites.findByUserAndResource(r.tenantId, r.userId, r.resourceId);
    if (!fav.isNull)      
      return CommandResult(true, fav.id.value, "");

    fav = Favorite();
    fav.initEntity(r.tenantId);
    fav.userId = r.userId;
    fav.resourceId = r.resourceId;
    fav.resourceType = r.resourceType;

    favorites.save(fav);
    return CommandResult(true, fav.id.value, "");
  }

  /// Get user favorites.
  Favorite[] getFavorites(TenantId tenantId, UserId userId) {
    return favorites.findByUser(tenantId, userId);
  }
struct FolderContents {
  Folder[] subfolders;
  Document[] documents;
}
  /// Remove a favorite.
  CommandResult deleteFavorite(TenantId tenantId, FavoriteId favoriteId) {
    auto favorite = favorites.findById(tenantId, favoriteId);
    if (favorite.isNull)
      return CommandResult(false, "", "Favorite not found");

    favorites.remove(favorite);
    return CommandResult(true, favorite.id.value, "");
  }
}


