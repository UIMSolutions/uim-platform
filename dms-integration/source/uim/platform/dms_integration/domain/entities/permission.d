/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.entities.permission;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

struct Permission {
    mixin TenantEntity!PermissionId;

    RepositoryId repositoryId;
    DocumentId documentId;
    FolderId folderId;
    string principalId;
    PrincipalType principalType = PrincipalType.user;
    PermissionType permissionType = PermissionType.read;
    bool isInherited = false;
    bool isDirect = true;
    string grantedAt;
    UserId grantedBy;
    string expiresAt;
    string description;

    Json toJson() const {
        return entityToJson
            .set("repositoryId", repositoryId.value)
            .set("documentId", documentId.value)
            .set("folderId", folderId.value)
            .set("principalId", principalId)
            .set("principalType", principalType.to!string)
            .set("permissionType", permissionType.to!string)
            .set("isInherited", isInherited)
            .set("isDirect", isDirect)
            .set("grantedAt", grantedAt)
            .set("grantedBy", grantedBy.value)
            .set("expiresAt", expiresAt)
            .set("description", description);
    }
}
