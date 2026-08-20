/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.ports.usecases.document_versions;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface IManageDocumentVersionsUseCase {

    DocumentVersion getDocumentVersion(TenantId tenantId, DocumentVersionId id);

    DocumentVersion[] listVersionsByDocument(TenantId tenantId, DocumentId documentId);

    DocumentVersion[] listMajorVersions(TenantId tenantId, DocumentId documentId);

    DocumentVersion[] listLatestVersions(TenantId tenantId, DocumentId documentId);

    UsecaseResult createDocumentVersion(DocumentVersionDTO dto);

    UsecaseResult deleteDocumentVersion(TenantId tenantId, DocumentVersionId id);

}
