/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.container;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

struct Container {
    ManageRepositoriesUseCase manageRepositoriesUseCase;
    ManageDocumentsUseCase manageDocumentsUseCase;
    ManageFoldersUseCase manageFoldersUseCase;
    ManageDocumentVersionsUseCase manageDocumentVersionsUseCase;
    ManagePermissionsUseCase managePermissionsUseCase;

    RepositoryController repositoryController;
    DocumentController documentController;
    FolderController folderController;
    DocumentVersionController documentVersionController;
    PermissionController permissionController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto repositoryRepo = new MemoryRepositoryRepository();
    auto documentRepo = new MemoryDocumentRepository();
    auto folderRepo = new MemoryFolderRepository();
    auto documentVersionRepo = new MemoryDocumentVersionRepository();
    auto permissionRepo = new MemoryPermissionRepository();

    // Use Cases
    c.manageRepositoriesUseCase = new ManageRepositoriesUseCase(repositoryRepo);
    c.manageDocumentsUseCase = new ManageDocumentsUseCase(documentRepo);
    c.manageFoldersUseCase = new ManageFoldersUseCase(folderRepo);
    c.manageDocumentVersionsUseCase = new ManageDocumentVersionsUseCase(documentVersionRepo);
    c.managePermissionsUseCase = new ManagePermissionsUseCase(permissionRepo);

    // Controllers
    c.repositoryController = new RepositoryController(c.manageRepositoriesUseCase);
    c.documentController = new DocumentController(c.manageDocumentsUseCase);
    c.folderController = new FolderController(c.manageFoldersUseCase);
    c.documentVersionController = new DocumentVersionController(c.manageDocumentVersionsUseCase);
    c.permissionController = new PermissionController(c.managePermissionsUseCase);
    c.healthController = new HealthController();

    return c;
}
