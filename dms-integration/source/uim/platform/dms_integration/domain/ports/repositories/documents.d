/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.ports.repositories.documents;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface IDocumentRepository : ITenantRepository!(DmsDocument, DocumentId) {

    size_t countByRepository(TenantId tenantId, RepositoryId repositoryId);
    DmsDocument[] findByRepository(TenantId tenantId, RepositoryId repositoryId);
    void removeByRepository(TenantId tenantId, RepositoryId repositoryId);

    size_t countByFolder(TenantId tenantId, FolderId folderId);
    DmsDocument[] findByFolder(TenantId tenantId, FolderId folderId);
    void removeByFolder(TenantId tenantId, FolderId folderId);

    size_t countByStatus(TenantId tenantId, DocumentStatus status);
    DmsDocument[] findByStatus(TenantId tenantId, DocumentStatus status);

    DmsDocument[] findCheckedOut(TenantId tenantId);
    DmsDocument[] findCheckedOutBy(TenantId tenantId, UserId userId);

    DmsDocument[] searchByName(TenantId tenantId, string searchTerm);
}
