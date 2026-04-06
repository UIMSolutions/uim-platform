/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.entities.document;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct Document {
    DocumentId id;
    TenantId tenantId;
    string equipmentId;
    string modelId;
    string name;
    string description;
    DocumentType documentType = DocumentType.manual;
    DocumentStatus status = DocumentStatus.draft;
    string version_;
    string fileName;
    string fileSize;
    string mimeType;
    string language;
    string uploadedBy;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
