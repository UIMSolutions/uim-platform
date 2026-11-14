/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.rest.interfaces.label;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// vibe.d REST interface: labels (tenant from the X-Tenant-ID header).
interface ILabelApi {
  /// GET /rest/v1/labels
  @path("/labels") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  @queryParam("resourceType", "resourceType")
  @queryParam("resourceId", "resourceId")
  @queryParam("key", "key")
  Json listLabels(string tenantId, string resourceType = "", string resourceId = "", string key = "");

  /// GET /rest/v1/labels/:id
  @path("/labels/:id") @method(HTTPMethod.GET)
  @headerParam("tenantId", "X-Tenant-ID")
  Json getLabel(string tenantId, string _id);
}
