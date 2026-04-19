/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms.application.infrastructure.container;

// import uim.platform.dms.application.infrastructure.config;
// 
// // Repositories
// import uim.platform.dms.application.infrastructure.persistence.memory.repository;
// import uim.platform.dms.application.infrastructure.persistence.memory.folder;
// import uim.platform.dms.application.infrastructure.persistence.memory.document;
// import uim.platform.dms.application.infrastructure.persistence.memory.document_version;
// import uim.platform.dms.application.infrastructure.persistence.memory.share;
// import uim.platform.dms.application.infrastructure.persistence.memory.permission;
// import uim.platform.dms.application.infrastructure.persistence.memory.favorite;
// 
// // Domain services
// import uim.platform.dms.application.domain.services.versioning_service;
// import uim.platform.dms.application.domain.services.access_control_service;
// 
// // Use cases
// import uim.platform.dms.application.application.usecases.manage.repositories;
// import uim.platform.dms.application.application.usecases.manage.folders;
// import uim.platform.dms.application.application.usecases.manage.documents;
// import uim.platform.dms.application.application.usecases.manage.versions;
// import uim.platform.dms.application.application.usecases.manage.shares;
// import uim.platform.dms.application.application.usecases.manage.permissions;
// import uim.platform.dms.application.application.usecases.browse_content;
// 
// // Controllers
// import uim.platform.dms.application.presentation.http.repository;
// import uim.platform.dms.application.presentation.http.folder;
// import uim.platform.dms.application.presentation.http.document;
// import uim.platform.dms.application.presentation.http.version_;
// import uim.platform.dms.application.presentation.http.share;
// import uim.platform.dms.application.presentation.http.permission;
// import uim.platform.dms.application.presentation.http.browse;
// import uim.platform.dms.application.presentation.http.health;

import uim.platform.dms.application;

mixin(ShowModule!());

@safe:
/// Dependency injection container - wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemoryRepositoryRepository repoRepo;
  MemoryFolderRepository folderRepo;
  MemoryDocumentRepository docRepo;
  MemoryDocumentVersionRepository versionRepo;
  MemoryShareRepository shareRepo;
  MemoryPermissionRepository permRepo;
  MemoryFavoriteRepository favRepo;

  // Domain services
  VersioningService versioningService;
  AccessControlService accessControlService;

  // Use cases (application layer)
  ManageRepositoriesUseCase manageRepositories;
  ManageFoldersUseCase manageFolders;
  ManageDocumentsUseCase manageDocuments;
  ManageVersionsUseCase manageVersions;
  ManageSharesUseCase manageShares;
  ManagePermissionsUseCase managePermissions;
  BrowseContentUseCase browseContent;

  // Controllers (driving adapters)
  RepositoryController repositoryController;
  FolderController folderController;
  DocumentController documentController;
  VersionController versionController;
  ShareController shareController;
  PermissionController permissionController;
  BrowseController browseController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.repoRepo = new MemoryRepositoryRepository();
  c.folderRepo = new MemoryFolderRepository();
  c.docRepo = new MemoryDocumentRepository();
  c.versionRepo = new MemoryDocumentVersionRepository();
  c.shareRepo = new MemoryShareRepository();
  c.permRepo = new MemoryPermissionRepository();
  c.favRepo = new MemoryFavoriteRepository();

  // Domain services
  c.versioningService = new VersioningService(c.docRepo, c.versionRepo);
  c.accessControlService = new AccessControlService(c.permRepo);

  // Application use cases
  c.manageRepositories = new ManageRepositoriesUseCase(c.repoRepo);
  c.manageFolders = new ManageFoldersUseCase(c.folderRepo, c.repoRepo);
  c.manageDocuments = new ManageDocumentsUseCase(c.docRepo, c.versionRepo, c.folderRepo);
  c.manageVersions = new ManageVersionsUseCase(c.versioningService);
  c.manageShares = new ManageSharesUseCase(c.shareRepo, c.docRepo);
  c.managePermissions = new ManagePermissionsUseCase(c.permRepo, c.accessControlService);
  c.browseContent = new BrowseContentUseCase(c.docRepo, c.folderRepo, c.favRepo, c.repoRepo);

  // Presentation controllers
  c.repositoryController = new RepositoryController(c.manageRepositories);
  c.folderController = new FolderController(c.manageFolders);
  c.documentController = new DocumentController(c.manageDocuments);
  c.versionController = new VersionController(c.manageVersions);
  c.shareController = new ShareController(c.manageShares);
  c.permissionController = new PermissionController(c.managePermissions);
  c.browseController = new BrowseController(c.browseContent);
  c.healthController = new HealthController("dms-application");

  return c;
}
