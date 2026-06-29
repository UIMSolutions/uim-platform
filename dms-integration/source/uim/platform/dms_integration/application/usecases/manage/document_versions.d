/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.application.usecases.manage.document_versions;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

class ManageDocumentVersionsUseCase {
    private DocumentVersionRepository repo;

    this(DocumentVersionRepository repo) {
        this.repo = repo;
    }

    DocumentVersion getDocumentVersion(TenantId tenantId, DocumentVersionId id) {
        return repo.findById(tenantId, id);
    }

    DocumentVersion[] listVersionsByDocument(TenantId tenantId, DocumentId documentId) {
        return repo.findByDocument(tenantId, documentId);
    }

    DocumentVersion[] listMajorVersions(TenantId tenantId, DocumentId documentId) {
        return repo.findMajorVersions(tenantId, documentId);
    }

    DocumentVersion[] listLatestVersions(TenantId tenantId, DocumentId documentId) {
        return repo.findLatestVersions(tenantId, documentId);
    }

    CommandResult createDocumentVersion(DocumentVersionDTO dto) {
        DocumentVersion ver;
        ver.id = dto.documentVersionId;
        ver.tenantId = dto.tenantId;
        ver.documentId = dto.documentId;
        ver.repositoryId = dto.repositoryId;
        ver.versionLabel = dto.versionLabel;
        ver.isMajorVersion = dto.isMajorVersion;
        ver.comment = dto.comment;
        ver.fileSizeBytes = dto.fileSizeBytes;
        ver.mimeType = dto.mimeType;
        ver.fileName = dto.fileName;
        ver.checksum = dto.checksum;
        ver.contentStreamId = dto.contentStreamId;
        ver.checkinComment = dto.checkinComment;
        ver.createdByVersion = dto.createdBy;
        ver.isLatestVersion = true;
        ver.createdBy = dto.createdBy;
        if (!DmsValidator.isValidDocumentVersion(ver))
            return CommandResult(false, "", "Invalid document version: documentId and versionLabel are required");
        repo.save(ver);
        return CommandResult(true, ver.id.value, "");
    }

    CommandResult deleteDocumentVersion(TenantId tenantId, DocumentVersionId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Document version not found");
        if (existing.isLatestVersion)
            return CommandResult(false, "", "Cannot delete the latest version");
        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
