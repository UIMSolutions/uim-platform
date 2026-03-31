module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_repository_repo;
import infrastructure.persistence.in_memory_folder_repo;
import infrastructure.persistence.in_memory_document_repo;
import infrastructure.persistence.in_memory_document_version_repo;
import infrastructure.persistence.in_memory_share_repo;
import infrastructure.persistence.in_memory_permission_repo;
import infrastructure.persistence.in_memory_favorite_repo;

// Domain services
import domain.services.versioning_service;
import domain.services.access_control_service;

// Use cases
import application.usecases.manage_repositories;
import application.usecases.manage_folders;
import application.usecases.manage_documents;
import application.usecases.manage_versions;
import application.usecases.manage_shares;
import application.usecases.manage_permissions;
import application.usecases.browse_content;

// Controllers
import presentation.http.repository_controller;
import presentation.http.folder_controller;
import presentation.http.document_controller;
import presentation.http.version_controller;
import presentation.http.share_controller;
import presentation.http.permission_controller;
import presentation.http.browse_controller;
import presentation.http.health_controller;

/// Dependency injection container - wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  InMemoryRepositoryRepository repoRepo;
  InMemoryFolderRepository folderRepo;
  InMemoryDocumentRepository docRepo;
  InMemoryDocumentVersionRepository versionRepo;
  InMemoryShareRepository shareRepo;
  InMemoryPermissionRepository permRepo;
  InMemoryFavoriteRepository favRepo;

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
Container buildContainer(AppConfig config)
{
  Container c;

  // Infrastructure adapters
  c.repoRepo = new InMemoryRepositoryRepository();
  c.folderRepo = new InMemoryFolderRepository();
  c.docRepo = new InMemoryDocumentRepository();
  c.versionRepo = new InMemoryDocumentVersionRepository();
  c.shareRepo = new InMemoryShareRepository();
  c.permRepo = new InMemoryPermissionRepository();
  c.favRepo = new InMemoryFavoriteRepository();

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
  c.healthController = new HealthController();

  return c;
}
