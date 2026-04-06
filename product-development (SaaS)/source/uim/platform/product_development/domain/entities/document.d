/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.document;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct Document {
    DocumentId id;
    TenantId tenantId;
    string productId;
    string name;
    string description;
    DocumentType documentType = DocumentType.drawing;
    DocumentStatus status = DocumentStatus.draft;
    string version_;
    string fileName;
    string mimeType;
    string fileSize;
    string documentNumber;
    string language;
    string author;
    string approvedBy;
    string validFrom;
    string validTo;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
