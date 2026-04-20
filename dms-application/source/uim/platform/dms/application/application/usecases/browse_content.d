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
  string repositoryId;
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
    RepositorySummary summary;
    if (!repositories.existsById(tenantId, repositoryId))
      return summary;

    auto repo = repositories.findById(tenantId, repositoryId);
    summary.repositoryId = RepositoryId(repositoryId);
    summary.name = repo.name;
    summary.totalDocuments = docs.countByRepository(tenantId, repositoryId);
    summary.totalFolders = folders.findByRepository(tenantId, repositoryId).length;
    summary.status = repo.status;
    return summary;
  }

  /// Add a favorite.
  CommandResult addFavorite(CreateFavoriteRequest r) {
    // Check for duplicate
    if (favorites.existsByUserAndResource(r.tenantId, r.userId, r.resourceId))
      return CommandResult(true, existing.id.toString(), "");

    auto fav = new Favorite();
    fav.id = randomUUID();
    fav.tenantId = r.tenantId;
    fav.userId = r.userId;
    fav.resourceId = r.resourceId;
    fav.resourceType = r.resourceType;
    fav.createdAt = Clock.currStdTime();

    favorites.save(fav);
    return CommandResult(true, fav.id.toString(), "");
  }

  /// Get user favorites.
  Favorite[] getFavorites(TenantId tenantId, UserId userId) {
    return favorites.findByUser(tenantId, userId);
  }

  /// Remove a favorite.
  CommandResult removeFavorite(TenantId tenantId, FavoriteId favoriteId) {
    if (!favorites.existsById(tenantId, favoriteId))
      return CommandResult(false, "", "Favorite not found");

    favorites.remove(tenantId, favoriteId);
    return CommandResult(true, favoriteId.toString(), "");
  }
}

struct FolderContents {
  Folder[] subfolders;
  Document[] documents;
}
