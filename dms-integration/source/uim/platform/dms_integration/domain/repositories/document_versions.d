/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.repositories.document_versions;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface DocumentVersionRepository : ITenantRepository!(DocumentVersion, DocumentVersionId) {

    DocumentVersion[] findByDocument(TenantId tenantId, DocumentId documentId);
    void removeByDocument(TenantId tenantId, DocumentId documentId);

    DocumentVersion[] findByRepository(TenantId tenantId, RepositoryId repositoryId);

    DocumentVersion[] findLatestVersions(TenantId tenantId, DocumentId documentId);
    DocumentVersion[] findMajorVersions(TenantId tenantId, DocumentId documentId);
}
