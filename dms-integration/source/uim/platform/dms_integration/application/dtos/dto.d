/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.application.dtos.dto;

import uim.platform.dms_integration;
mixin(ShowModule!());

@safe:

struct RepositoryDTO {
    RepositoryId repositoryId;
    TenantId tenantId;
    string name;
    string description;
    string repositoryType;
    string status;
    bool isDefault;
    string externalUrl;
    string cmisVersion;
    bool encryptionEnabled;
    long capacityLimitBytes;
    string repositoryKey;
    string externalRepositoryId;
    string region;
    bool isReadOnly;
    bool versioningEnabled;
    bool fullTextSearchEnabled;
    UserId createdBy;
    UserId updatedBy;
}

struct DocumentDTO {
    DocumentId documentId;
    TenantId tenantId;
    RepositoryId repositoryId;
    FolderId folderId;
    string name;
    string description;
    string mimeType;
    long fileSizeBytes;
    string fileName;
    string fileExtension;
    string documentStatus;
    string lifecycleStatus;
    string versioningState;
    string versionLabel;
    bool isMajorVersion;
    string language;
    string tags;
    string externalId;
    string sourceSystem;
    string externalLink;
    string validFrom;
    string validTo;
    string searchContent;
    string customProperties;
    UserId createdBy;
    UserId updatedBy;
}

struct FolderDTO {
    FolderId folderId;
    TenantId tenantId;
    RepositoryId repositoryId;
    FolderId parentFolderId;
    string name;
    string description;
    string path;
    int depth;
    string folderType;
    bool isSystemFolder;
    string allowedDocumentTypes;
    bool inheritPermissions;
    bool isReadOnly;
    string externalId;
    string customProperties;
    UserId createdBy;
    UserId updatedBy;
}

struct DocumentVersionDTO {
    DocumentVersionId documentVersionId;
    TenantId tenantId;
    DocumentId documentId;
    RepositoryId repositoryId;
    string versionLabel;
    bool isMajorVersion;
    string comment;
    long fileSizeBytes;
    string mimeType;
    string fileName;
    string checksum;
    string contentStreamId;
    string checkinComment;
    UserId createdBy;
}

struct PermissionDTO {
    PermissionId permissionId;
    TenantId tenantId;
    RepositoryId repositoryId;
    DocumentId documentId;
    FolderId folderId;
    string principalId;
    string principalType;
    string permissionType;
    bool isInherited;
    bool isDirect;
    long expiresAt;
    string description;
    UserId grantedBy;
}
