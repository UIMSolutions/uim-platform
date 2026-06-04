/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.role_collection;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class RoleCollectionController : ManageHttpController {
  private ManageRoleCollectionsUseCase usecase;

  this(ManageRoleCollectionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/role-collections", &handleCreate);
    router.get("/api/v1/role-collections", &handleList);
    router.get("/api/v1/role-collections/*", &handleGet);
    router.put("/api/v1/role-collections/*", &handleUpdate);
    router.delete_("/api/v1/role-collections/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto rcs = usecase.listRoleCollections(tenantId);
    auto jarr = rcs.map!(rc => rc.toJson).array.toJson;

    auto response = Json.emptyObject
      .set("items", jarr)
      .set("totalCount", rcs.length);

    return successResponse("Role collection list retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateRoleCollectionRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.roleReferences = data.getArray("roleReferences").map!(e => e.getString).array;

    auto result = usecase.createRoleCollection(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Role collection created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = RoleCollectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid role collection ID", 400);

    auto rc = usecase.getRoleCollection(tenantId, id);
    if (rc.isNull)
      return errorResponse("Role collection not found", 404);

    auto responseData = rc.toJson();
    return successResponse("Role collection retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RoleCollectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid role collection ID", 400);

    auto data = precheck.data;
    UpdateRoleCollectionRequest r;
    r.tenantId = tenantId;
    r.collectionId = id;
    // r.name = data.getString("name");
    r.description = data.getString("description");
    r.roleReferences = data.getArray("roleReferences").map!(e => e.getString).array;

    auto result = usecase.updateRoleCollection(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Role collection updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = RoleCollectionId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid role collection ID", 400);

    auto result = usecase.deleteRoleCollection(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Role collection deleted successfully", "Deleted", 200, responseData);
  }
}
