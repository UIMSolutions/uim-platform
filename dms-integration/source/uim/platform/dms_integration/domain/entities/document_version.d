/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.entities.document_version;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

struct DocumentVersion {
    mixin TenantEntity!DocumentVersionId;

    DocumentId documentId;
    RepositoryId repositoryId;
    string versionLabel;
    bool isMajorVersion = true;
    bool isLatestVersion = false;
    string comment;
    long fileSizeBytes = 0;
    string mimeType;
    string fileName;
    string checksum;
    string contentStreamId;
    string checkinComment;
    UserId createdByVersion;
    long versionedAt;

    Json toJson() const {
        return entityToJson
            .set("documentId", documentId.value)
            .set("repositoryId", repositoryId.value)
            .set("versionLabel", versionLabel)
            .set("isMajorVersion", isMajorVersion)
            .set("isLatestVersion", isLatestVersion)
            .set("comment", comment)
            .set("fileSizeBytes", fileSizeBytes)
            .set("mimeType", mimeType)
            .set("fileName", fileName)
            .set("checksum", checksum)
            .set("contentStreamId", contentStreamId)
            .set("checkinComment", checkinComment)
            .set("createdByVersion", createdByVersion.value)
            .set("versionedAt", versionedAt);
    }
}
