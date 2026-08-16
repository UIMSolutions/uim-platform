/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.ports.usecases.folders;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface IManageFoldersUseCase {

    Folder getFolder(TenantId tenantId, FolderId id);

    Folder[] listFolders(TenantId tenantId);

    Folder[] listFoldersByRepository(TenantId tenantId, RepositoryId repositoryId);

    Folder[] listSubFolders(TenantId tenantId, FolderId parentFolderId);

    Folder[] listRootFolders(TenantId tenantId, RepositoryId repositoryId);

    CommandResult createFolder(FolderDTO dto);

    CommandResult updateFolder(FolderDTO dto);

    CommandResult moveFolder(TenantId tenantId, FolderId id, FolderId targetParentId, UserId userId);

    CommandResult deleteFolder(TenantId tenantId, FolderId id);

}
