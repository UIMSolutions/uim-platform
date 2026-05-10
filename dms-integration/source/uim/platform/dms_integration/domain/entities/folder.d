/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.entities.folder;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

struct Folder {
    mixin TenantEntity!FolderId;

    RepositoryId repositoryId;
    FolderId parentFolderId;
    string name;
    string description;
    string path;
    int depth = 0;
    FolderType folderType = FolderType.standard;
    bool isSystemFolder = false;
    long documentCount = 0;
    long subFolderCount = 0;
    long totalSizeBytes = 0;
    string allowedDocumentTypes;
    bool inheritPermissions = true;
    bool isReadOnly = false;
    string externalId;
    string customProperties;

    Json toJson() const {
        return entityToJson
            .set("repositoryId", repositoryId.value)
            .set("parentFolderId", parentFolderId.value)
            .set("name", name)
            .set("description", description)
            .set("path", path)
            .set("depth", depth)
            .set("folderType", folderType.to!string)
            .set("isSystemFolder", isSystemFolder)
            .set("documentCount", documentCount)
            .set("subFolderCount", subFolderCount)
            .set("totalSizeBytes", totalSizeBytes)
            .set("allowedDocumentTypes", allowedDocumentTypes)
            .set("inheritPermissions", inheritPermissions)
            .set("isReadOnly", isReadOnly)
            .set("externalId", externalId)
            .set("customProperties", customProperties);
    }
}
