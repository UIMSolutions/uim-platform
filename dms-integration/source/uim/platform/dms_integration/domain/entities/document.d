/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.entities.document;

import uim.platform.dms_integration;
mixin(ShowModule!());

@safe:

struct Document {
    mixin TenantEntity!DocumentId;

    RepositoryId repositoryId;
    FolderId folderId;
    string name;
    string description;
    string mimeType;
    long fileSizeBytes = 0;
    string fileName;
    string fileExtension;
    DocumentStatus documentStatus = DocumentStatus.draft;
    LifecycleStatus lifecycleStatus = LifecycleStatus.draft;
    VersioningState versioningState = VersioningState.none;
    CheckoutStatus checkoutStatus = CheckoutStatus.available;
    string versionLabel;
    bool isMajorVersion = true;
    bool isLatestVersion = true;
    UserId checkedOutBy;
    long checkedOutAt;
    string contentStreamId;
    string checksum;
    string language;
    string tags;
    string externalId;
    string sourceSystem;
    string externalLink;
    string validFrom;
    string validTo;
    string searchContent;
    string customProperties;

    Json toJson() const {
        return entityToJson
            .set("repositoryId", repositoryId.value)
            .set("folderId", folderId.value)
            .set("name", name)
            .set("description", description)
            .set("mimeType", mimeType)
            .set("fileSizeBytes", fileSizeBytes)
            .set("fileName", fileName)
            .set("fileExtension", fileExtension)
            .set("documentStatus", documentStatus.to!string)
            .set("lifecycleStatus", lifecycleStatus.to!string)
            .set("versioningState", versioningState.to!string)
            .set("checkoutStatus", checkoutStatus.to!string)
            .set("versionLabel", versionLabel)
            .set("isMajorVersion", isMajorVersion)
            .set("isLatestVersion", isLatestVersion)
            .set("checkedOutBy", checkedOutBy.value)
            .set("checkedOutAt", checkedOutAt)
            .set("contentStreamId", contentStreamId)
            .set("checksum", checksum)
            .set("language", language)
            .set("tags", tags)
            .set("externalId", externalId)
            .set("sourceSystem", sourceSystem)
            .set("externalLink", externalLink)
            .set("validFrom", validFrom)
            .set("validTo", validTo)
            .set("searchContent", searchContent)
            .set("customProperties", customProperties);
    }
}
