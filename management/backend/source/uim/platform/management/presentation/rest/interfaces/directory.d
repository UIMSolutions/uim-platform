/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: directories (tenant from the X-Tenant-ID header).
interface IDirectoryApi {
  /// GET /rest/v1/directories
  @path("/directories") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("globalAccountId", "globalAccountId")
  @queryParam("parentDirectoryId", "parentDirectoryId")
  Json listDirectories(string tenantId, string globalAccountId = "", string parentDirectoryId = "");

  /// GET /rest/v1/directories/:id
  @path("/directories/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getDirectory(string tenantId, string _id);

  /// POST /rest/v1/directories
  @path("/directories") @method(HTTPMethod.POST)
  @headerParam("tenantId", "X-Tenant-ID")
  Json createDirectory(string tenantId, CreateDirectoryRequest request);
}
