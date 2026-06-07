/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.presentation.http.controllers.fragment;

// import uim.platform.destination.application.usecases.manage.fragments;
// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.destination_fragment;
// import uim.platform.destination.domain.types;
import uim.platform.destination;

// mixin(ShowModule!());

@safe:
class FragmentController : ManageHttpController {
  private ManageFragmentsUseCase usecase;

  this(ManageFragmentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/fragments", &handleCreate);
    router.get("/api/v1/fragments", &handleList);
    router.get("/api/v1/fragments/*", &handleGet);
    router.put("/api/v1/fragments/*", &handleUpdate);
    router.delete_("/api/v1/fragments/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));

    auto fragments = usecase.listBySubaccount(tenantId, subaccountId);
    auto arr = fragments.map!(f => f.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", Json(fragments.length));

    return successResponse("Fragments retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateFragmentRequest r;
    r.tenantId = tenantId;
    r.subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.level = data.getString("level");
    r.url = data.getString("url");
    r.authenticationType = data.getString("authentication");
    r.proxyType = data.getString("proxyType");
    r.user = data.getString("user");
    r.password = data.getString("password");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenServiceUrl = data.getString("tokenServiceURL");
    r.locationId = data.getString("locationId");
    r.keystoreId = data.getString("keystoreId");
    r.truststoreId = data.getString("truststoreId");
    r.properties = data.jsonStrMap("properties");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createFragment(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Fragment created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = DestinationFragmentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid fragment ID", 400);

    auto f = usecase.getFragment(tenantId, id);
    if (f.isNull)
      return errorResponse("Fragment not found", 404);

    auto responseData = f.toJson();
    return successResponse("Fragment retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = DestinationFragmentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid fragment ID", 400);

    auto data = precheck.data;
    UpdateFragmentRequest r;
    r.tenantId = tenantId;
    r.fragmentId = id;
    r.description = data.getString("description");
    r.url = data.getString("url");
    r.authenticationType = data.getString("authentication");
    r.proxyType = data.getString("proxyType");
    r.user = data.getString("user");
    r.password = data.getString("password");
    r.clientId = data.getString("clientId");
    r.clientSecret = data.getString("clientSecret");
    r.tokenServiceUrl = data.getString("tokenServiceURL");
    r.locationId = data.getString("locationId");
    r.keystoreId = data.getString("keystoreId");
    r.truststoreId = data.getString("truststoreId");
    r.properties = data.jsonStrMap("properties");

    auto result = usecase.updateFragment(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Fragment updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DestinationFragmentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid fragment ID", 400);

    auto result = usecase.deleteFragment(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Fragment deleted successfully", "Deleted", 200, responseData);
  }
}
