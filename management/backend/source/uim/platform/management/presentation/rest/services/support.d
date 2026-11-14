/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Shared helpers of the REST services.
module uim.platform.management.presentation.rest.services.support;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// The tenant of a request; the X-Tenant-ID header is mandatory.
TenantId tenant(string tenantId) {
  if (tenantId.length == 0)
    throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
  return TenantId(tenantId);
}

/// { "count": n, "resources": [...] }
Json collectionOf(T)(T[] items) {
  auto list = Json.emptyArray;
  foreach (item; items)
    list ~= item.toJson;
  return Json.emptyObject.set("count", items.length).set("resources", list);
}

/// The entity as JSON, or HTTP 404.
Json entityOrNotFound(T)(T entity, string what) {
  if (entity.isNull)
    throw new HTTPStatusException(HTTPStatus.notFound, what ~ " not found");
  return entity.toJson;
}

/// A use case result as JSON; failures become HTTP errors with the result code.
Json resultOf(UsecaseResult result) {
  if (!result.isSuccess) {
    auto status = result.code >= 400 && result.code < 600 ? cast(int) result.code : 400;
    throw new HTTPStatusException(status, result.message);
  }
  return result.toJson;
}
