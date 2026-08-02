/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.infrastructure.persistence.repositories.document_versions;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

class DocumentVersionRepository : TenantRepository!(DocumentVersion, DocumentVersionId), IDocumentVersionRepository {


    size_t countByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return findByRepository(tenantId, repositoryId).length;
    }

    DocumentVersion[] filterByRepository(DocumentVersion[] versions, RepositoryId repositoryId) {
        return versions.filter!(e => e.repositoryId == repositoryId).array;
    }

    DocumentVersion[] findByRepository(TenantId tenantId, RepositoryId repositoryId) {
        return filterByRepository(findByTenant(tenantId), repositoryId);
    }

    void removeByRepository(TenantId tenantId, RepositoryId repositoryId) {
        findByRepository(tenantId, repositoryId).each!(e => remove(e));
    }

    size_t countByDocument(TenantId tenantId, DocumentId documentId) {
        return findByDocument(tenantId, documentId).length;
    }

    DocumentVersion[] filterByDocument(DocumentVersion[] versions, DocumentId documentId) {
        return versions.filter!(e => e.documentId == documentId).array;
    }

    DocumentVersion[] findByDocument(TenantId tenantId, DocumentId documentId) {
        return filterByDocument(findByTenant(tenantId), documentId);
    }

    void removeByDocument(TenantId tenantId, DocumentId documentId) {
        findByDocument(tenantId, documentId).each!(e => remove(e));
    }

    size_t countLatestVersions(TenantId tenantId, DocumentId documentId) {
        return findLatestVersions(tenantId, documentId).length;
    }

    DocumentVersion[] filterLatestVersions(DocumentVersion[] versions, DocumentId documentId) {
        return versions.filter!(e => e.documentId == documentId && e.isLatestVersion).array;
    }

    DocumentVersion[] findLatestVersions(TenantId tenantId, DocumentId documentId) {
        return filterLatestVersions(findByDocument(tenantId, documentId), documentId);
    }

    void removeLatestVersions(TenantId tenantId, DocumentId documentId) {
        findLatestVersions(tenantId, documentId).each!(e => remove(e));
    }

    size_t countMajorVersions(TenantId tenantId, DocumentId documentId) {
        return findMajorVersions(tenantId, documentId).length;
    }

    DocumentVersion[] filterMajorVersions(DocumentVersion[] versions, DocumentId documentId) {
        return versions.filter!(e => e.documentId == documentId && e.isMajorVersion).array;
    }

    DocumentVersion[] findMajorVersions(TenantId tenantId, DocumentId documentId) {
        return filterMajorVersions(findByDocument(tenantId, documentId), documentId);
    }

    void removeMajorVersions(TenantId tenantId, DocumentId documentId) {
        findMajorVersions(tenantId, documentId).each!(e => remove(e));
    }
}
