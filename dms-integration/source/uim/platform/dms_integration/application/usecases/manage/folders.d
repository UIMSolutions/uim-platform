/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.application.usecases.manage.folders;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

class ManageFoldersUseCase {
    private FolderRepository repo;

    this(FolderRepository repo) {
        this.repo = repo;
    }

    Folder getFolder(TenantId tenantId, FolderId id) {
        return repo.findById(tenantId, id);
    }

    Folder[] listFolders(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Folder[] listFoldersByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return repo.findByRepository(tenantId, repositoryId);
    }

    Folder[] listSubFolders(TenantId tenantId, FolderId parentFolderId) {
        return repo.findByParent(tenantId, parentFolderId);
    }

    Folder[] listRootFolders(TenantId tenantId, RepositoryId repositoryId) {
        return repo.findRootFolders(tenantId, repositoryId);
    }

    CommandResult createFolder(FolderDTO dto) {
        auto folder = Folder(dto.tenantId);
        folder.repositoryId = dto.repositoryId;
        folder.parentFolderId = dto.parentFolderId;
        folder.name = dto.name;
        folder.description = dto.description;
        folder.path = dto.path;
        folder.depth = dto.depth;
        folder.isSystemFolder = dto.isSystemFolder;
        folder.allowedDocumentTypes = dto.allowedDocumentTypes;
        folder.inheritPermissions = dto.inheritPermissions;
        folder.isReadOnly = dto.isReadOnly;
        folder.externalId = dto.externalId;
        folder.customProperties = dto.customProperties;
        folder.createdBy = dto.createdBy;
        if (dto.folderType.length > 0) {
            
            try { folder.folderType = dto.folderType.to!FolderType; } catch (Exception) {}
        }
        if (!DmsValidator.isValidFolder(folder))
            return CommandResult(false, "", "Invalid folder: name and repositoryId are required");
        
        repo.save(folder);
        return CommandResult(true, folder.id.value, "");
    }

    CommandResult updateFolder(FolderDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.folderId);
        if (existing.isNull)
            return CommandResult(false, "", "Folder not found");
        if (existing.isSystemFolder)
            return CommandResult(false, "", "Cannot update system folder");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.allowedDocumentTypes.length > 0) existing.allowedDocumentTypes = dto.allowedDocumentTypes;
        existing.inheritPermissions = dto.inheritPermissions;
        if (dto.customProperties.length > 0) existing.customProperties = dto.customProperties;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult moveFolder(TenantId tenantId, FolderId id, FolderId targetParentId, UserId userId) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Folder not found");
        if (existing.isSystemFolder)
            return CommandResult(false, "", "Cannot move system folder");
        existing.parentFolderId = targetParentId;
        if (!userId.isEmpty) existing.updatedBy = userId;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteFolder(TenantId tenantId, FolderId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Folder not found");
        if (existing.isSystemFolder)
            return CommandResult(false, "", "Cannot delete system folder");
        if (existing.documentCount > 0)
            return CommandResult(false, "", "Folder contains documents. Remove all documents first");
        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
