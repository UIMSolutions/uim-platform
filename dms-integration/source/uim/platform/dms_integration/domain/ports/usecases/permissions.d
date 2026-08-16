/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.ports.usecases.permissions;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface IManagePermissionsUseCase {

    Permission getPermission(TenantId tenantId, PermissionId id);

    Permission[] listPermissions(TenantId tenantId);

    Permission[] listPermissionsByDocument(TenantId tenantId, DocumentId documentId);

    Permission[] listPermissionsByFolder(TenantId tenantId, FolderId folderId);

    Permission[] listPermissionsByPrincipal(TenantId tenantId, string principalId);

    CommandResult grantPermission(PermissionDTO dto);

    CommandResult revokePermission(TenantId tenantId, PermissionId id);

    CommandResult deletePermission(TenantId tenantId, PermissionId id);

}
