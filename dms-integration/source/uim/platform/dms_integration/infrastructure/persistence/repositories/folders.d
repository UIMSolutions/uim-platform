/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.persistence.repositories.folders;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class FolderRepository : TenantRepository!(Folder, FolderId), IFolderRepository {

    size_t countByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return findByRepository(tenantId, repositoryId).length;
    }

    Folder[] filterByRepository(Folder[] folders, RepositoryId repositoryId) {
        return folders.filter!(e => e.repositoryId == repositoryId).array;
    }

    Folder[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return filterByRepository(findByTenant(tenantId), repositoryId);
    }

    void removeByRepository(TenantId tenantId, RepositoryId repositoryId) {
        findByRepository(tenantId, repositoryId).each!(e => remove(e));
    }

    size_t countByParent(TenantId tenantId, FolderId parentFolderId) {
        return findByParent(tenantId, parentFolderId).length;
    }

    Folder[] filterByParent(Folder[] folders, FolderId parentFolderId) {
        return folders.filter!(e => e.parentFolderId == parentFolderId).array;
    }

    Folder[] findByParent(TenantId tenantId, FolderId parentFolderId) {
        return filterByParent(findByTenant(tenantId), parentFolderId);
    }

    void removeByParent(TenantId tenantId, FolderId parentFolderId) {
        findByParent(tenantId, parentFolderId).each!(e => remove(e));
    }

    size_t countByPath(TenantId tenantId, RepositoryId repositoryId, string path) {
        return findByPath(tenantId, repositoryId, path).length;
    }

    Folder[] filterByPath(Folder[] folders, string path) {
        return folders.filter!(e => e.path == path).array;
    }

    Folder[] findByPath(TenantId tenantId, RepositoryId repositoryId, string path) {
        return filterByPath(findByRepository(tenantId, repositoryId), path);
    }

    void removeByPath(TenantId tenantId, RepositoryId repositoryId, string path) {
        findByPath(tenantId, repositoryId, path).each!(e => remove(e));
    }

    size_t countRootFolders(TenantId tenantId, RepositoryId repositoryId) {
        return findRootFolders(tenantId, repositoryId).length;
    }

    Folder[] filterRootFolders(Folder[] folders) {
        return folders.filter!(e => e.depth == 0).array;
    }

    Folder[] findRootFolders(TenantId tenantId, RepositoryId repositoryId) {
        return filterRootFolders(findByRepository(tenantId, repositoryId));
    }

    void removeRootFolders(TenantId tenantId, RepositoryId repositoryId) {
        findRootFolders(tenantId, repositoryId).each!(e => remove(e));
    }
}
