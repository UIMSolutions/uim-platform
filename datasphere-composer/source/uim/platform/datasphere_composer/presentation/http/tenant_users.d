/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.tenant_users;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;
mixin(ShowModule!());

@safe:
class TenantUserController : ManageHttpController {
  private ManageTenantUsersUseCase usecase;

  this(ManageTenantUsersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/composer/users", &handleList);
    router.get("/api/v1/composer/users/*", &handleGet);
    router.post("/api/v1/composer/users", &handleCreate);
    router.put("/api/v1/composer/users/*", &handleUpdate);
    router.delete_("/api/v1/composer/users/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.list(tenantId);
    auto arr = Json.emptyArray;
    foreach (item; items)
      arr ~= item.toJson();
    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);

    return successResponse("Tenant user list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TenantUserId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid tenant user ID", 400);

    auto item = usecase.getById(tenantId, id);
    if (item.isNull)
      return errorResponse("Tenant user not found", 404);

    auto responseData = item.toJson();
    return successResponse("Tenant user retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateTenantUserRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.email = data.getString("email");
    r.firstName = data.getString("firstName");
    r.lastName = data.getString("lastName");
    r.role = data.getString("role");
    r.externalUserId = data.getString("externalUserId");
    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("User created successfully", "Created", 201, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateTenantUserRequest r;
    r.tenantId = tenantId;
    r.id = extractIdFromPath(req.requestPath.to!string);
    r.firstName = data.getString("firstName");
    r.lastName = data.getString("lastName");
    r.role = data.getString("role");
    r.active = data.getBoolean("active");
    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Tenant user updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = TenantUserId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid tenant user ID", 400);

    auto result = usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Tenant user deleted successfully", "Deleted", 200, responseData);
  }
}
