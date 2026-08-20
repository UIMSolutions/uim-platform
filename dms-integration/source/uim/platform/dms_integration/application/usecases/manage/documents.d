/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.application.usecases.manage.documents;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class ManageDocumentsUseCase {
    private IDocumentRepository repo;

    this(IDocumentRepository repo) {
        this.repo = repo;
    }

    DmsDocument getDocument(TenantId tenantId, DocumentId id) {
        return repo.findById(tenantId, id);
    }

    DmsDocument[] listDocuments(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DmsDocument[] listDocumentsByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return repo.findByRepository(tenantId, repositoryId);
    }

    DmsDocument[] listDocumentsByFolder(TenantId tenantId, FolderId folderId) {
        return repo.findByFolder(tenantId, folderId);
    }

    DmsDocument[] listDocumentsByStatus(TenantId tenantId, DocumentStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    DmsDocument[] listCheckedOutDocuments(TenantId tenantId) {
        return repo.findCheckedOut(tenantId);
    }

    DmsDocument[] searchDocumentsByName(TenantId tenantId, string searchTerm) {
        return repo.searchByName(tenantId, searchTerm);
    }

    UsecaseResult createDocument(DocumentDTO dto) {
        DmsDocument doc;
        doc.id = dto.documentId;
        doc.tenantId = dto.tenantId;
        doc.repositoryId = dto.repositoryId;
        doc.folderId = dto.folderId;
        doc.name = dto.name;
        doc.description = dto.description;
        doc.mimeType = dto.mimeType;
        doc.fileSizeBytes = dto.fileSizeBytes;
        doc.fileName = dto.fileName;
        doc.fileExtension = dto.fileExtension;
        doc.language = dto.language;
        doc.tags = dto.tags;
        doc.externalId = dto.externalId;
        doc.sourceSystem = dto.sourceSystem;
        doc.externalLink = dto.externalLink;
        doc.validFrom = dto.validFrom;
        doc.validTo = dto.validTo;
        doc.searchContent = dto.searchContent;
        doc.customProperties = dto.customProperties;
        doc.createdBy = dto.createdBy;
        doc.versionLabel = dto.versionLabel.length > 0 ? dto.versionLabel : "1.0";
        doc.isMajorVersion = dto.isMajorVersion;
        doc.isLatestVersion = true;
        doc.documentStatus = DocumentStatus.draft;
        doc.lifecycleStatus = LifecycleStatus.draft;
        doc.checkoutStatus = CheckoutStatus.available;
        if (!DmsValidator.isValidDocument(doc))
            return UsecaseResult(false, "", "Invalid document: name and repositoryId are required");
        repo.save(doc);
        return UsecaseResult(true, doc.id.value, "");
    }

    UsecaseResult updateDocument(DocumentDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.documentId);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        if (existing.checkoutStatus == CheckoutStatus.checkedOut &&
            existing.checkedOutBy != dto.updatedBy)
            return UsecaseResult(false, "", "DmsDocument is checked out by another user");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.tags.length > 0) existing.tags = dto.tags;
        if (dto.language.length > 0) existing.language = dto.language;
        if (dto.validFrom.length > 0) existing.validFrom = dto.validFrom;
        if (dto.validTo.length > 0) existing.validTo = dto.validTo;
        if (dto.customProperties.length > 0) existing.customProperties = dto.customProperties;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult checkoutDocument(TenantId tenantId, DocumentId id, UserId userId) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        if (existing.checkoutStatus == CheckoutStatus.checkedOut)
            return UsecaseResult(false, "", "DmsDocument is already checked out");
        existing.checkoutStatus = CheckoutStatus.checkedOut;
        existing.checkedOutBy = userId;
        
        import std.datetime.systime : Clock;
        existing.checkedOutAt = currentTimestamp;
        existing.versioningState = VersioningState.checkedOut;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult checkinDocument(TenantId tenantId, DocumentId id, UserId userId, bool isMajor, string comment) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        if (existing.checkoutStatus != CheckoutStatus.checkedOut)
            return UsecaseResult(false, "", "DmsDocument is not checked out");
        if (existing.checkedOutBy != userId)
            return UsecaseResult(false, "", "DmsDocument is checked out by another user");
        existing.checkoutStatus = CheckoutStatus.available;
        existing.versioningState = isMajor ? VersioningState.major : VersioningState.minor;
        existing.checkedOutBy = UserId("");
        existing.checkedOutAt = 0;
        existing.isMajorVersion = isMajor;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult cancelCheckout(TenantId tenantId, DocumentId id, UserId userId) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        if (existing.checkoutStatus != CheckoutStatus.checkedOut)
            return UsecaseResult(false, "", "DmsDocument is not checked out");
        existing.checkoutStatus = CheckoutStatus.available;
        existing.versioningState = VersioningState.none;
        existing.checkedOutBy = UserId("");
        existing.checkedOutAt = 0;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult moveDocument(TenantId tenantId, DocumentId id, FolderId targetFolderId, UserId userId) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        existing.folderId = targetFolderId;
        if (!userId.isEmpty) existing.updatedBy = userId;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult publishDocument(TenantId tenantId, DocumentId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        existing.documentStatus = DocumentStatus.active;
        existing.lifecycleStatus = LifecycleStatus.published;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult archiveDocument(TenantId tenantId, DocumentId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        existing.documentStatus = DocumentStatus.archived;
        existing.lifecycleStatus = LifecycleStatus.archived_;
        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteDocument(TenantId tenantId, DocumentId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return UsecaseResult(false, "", "DmsDocument not found");
        if (existing.checkoutStatus == CheckoutStatus.checkedOut)
            return UsecaseResult(false, "", "Cannot delete a checked out document");
        repo.remove(existing);
        return UsecaseResult(true, existing.id.value, "");
    }
}

///
unittest {
//     auto repo = new DocumentRepository();
//     auto usecase = new ManageDocumentsUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test create
//     DocumentDTO createDto;
//     createDto.tenantId = tenantId;
//     createDto.documentId = DocumentId("document-1");
//     createDto.name = "Test DmsDocument";
//     auto createResult = usecase.createDocument(createDto);
//     assert(createResult.success, createResult.message);
// 
//     // Test list
//     auto items = usecase.listDocuments(tenantId);
//     assert(items.length == 1);
// 
//     // Test get
//     auto item = usecase.getDocument(tenantId, DocumentId("document-1"));
//     assert(!item.isNull);
// 
//     // Test update
//     DocumentDTO updateDto;
//     updateDto.tenantId = tenantId;
//     updateDto.documentId = DocumentId("document-1");
//     updateDto.name = "Updated DmsDocument";
//     auto updateResult = usecase.updateDocument(updateDto);
//     assert(updateResult.success, updateResult.message);
// 
//     // Test delete
//     auto deleteResult = usecase.deleteDocument(tenantId, DocumentId("document-1"));
//     assert(deleteResult.success, deleteResult.message);
//     assert(usecase.listDocuments(tenantId).length == 0);
// 
}
