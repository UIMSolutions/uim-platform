/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.entities.print_document;

import uim.platform.print;

// mixin(ShowModule!());

@safe:

struct PrintDocument {
    mixin TenantEntity!(PrintDocumentId);

    string fileName;
    string mimeType;
    DocumentFormat format = DocumentFormat.pdf;
    long sizeBytes;
    string storageUri;
    string checksum;
    string description;
    long expiresAt;

    Json toJson() const {
        auto j = entityToJson
            .set("fileName", fileName)
            .set("mimeType", mimeType)
            .set("format", format.to!string)
            .set("sizeBytes", sizeBytes)
            .set("storageUri", storageUri)
            .set("checksum", checksum)
            .set("description", description)
            .set("expiresAt", expiresAt);
        return j;
    }
}
