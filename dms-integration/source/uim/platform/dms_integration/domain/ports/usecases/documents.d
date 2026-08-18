/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.ports.usecases.documents;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface IManageDocumentsUseCase {

    Document getDocument(TenantId tenantId, DocumentId id);

    Document[] listDocuments(TenantId tenantId);

    Document[] listDocumentsByRepository(TenantId tenantId, RepositoryId repositoryId);

    Document[] listDocumentsByFolder(TenantId tenantId, FolderId folderId);

    Document[] listDocumentsByStatus(TenantId tenantId, DocumentStatus status);

    Document[] listCheckedOutDocuments(TenantId tenantId);

    Document[] searchDocumentsByName(TenantId tenantId, string searchTerm);

    UsecaseResult createDocument(DocumentDTO dto);

    UsecaseResult updateDocument(DocumentDTO dto);

    UsecaseResult checkoutDocument(TenantId tenantId, DocumentId id, UserId userId);

    UsecaseResult checkinDocument(TenantId tenantId, DocumentId id, UserId userId, bool isMajor, string comment);

    UsecaseResult cancelCheckout(TenantId tenantId, DocumentId id, UserId userId);

    UsecaseResult moveDocument(TenantId tenantId, DocumentId id, FolderId targetFolderId, UserId userId);

    UsecaseResult publishDocument(TenantId tenantId, DocumentId id);

    UsecaseResult archiveDocument(TenantId tenantId, DocumentId id);

    UsecaseResult deleteDocument(TenantId tenantId, DocumentId id);

}
