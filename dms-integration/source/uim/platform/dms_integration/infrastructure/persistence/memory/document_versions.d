/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.persistence.memory.document_versions;

import uim.platform.dms_integration;

// mixin(ShowModule!());

@safe:

class MemoryDocumentVersionRepository : TenantRepository!(DocumentVersion, DocumentVersionId), DocumentVersionRepository {

    DocumentVersion[] findByDocument(TenantId tenantId, DocumentId documentId) {
        return find(tenantId).filter!(e => e.documentId == documentId).array;
    }
    void removeByDocument(TenantId tenantId, DocumentId documentId) {
        findByDocument(tenantId, documentId).each!(e => remove(e));
    }

    DocumentVersion[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return find(tenantId).filter!(e => e.repositoryId == repositoryId).array;
    }

    DocumentVersion[] findLatestVersions(TenantId tenantId, DocumentId documentId) {
        return findByDocument(tenantId, documentId).filter!(e => e.isLatestVersion).array;
    }

    DocumentVersion[] findMajorVersions(TenantId tenantId, DocumentId documentId) {
        return findByDocument(tenantId, documentId).filter!(e => e.isMajorVersion).array;
    }
}
