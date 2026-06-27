/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.presentation.http.controllers.private_endpoint;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
/// HTTP controller for private endpoint management and approval workflow.
class PrivateEndpointController : ManageHttpController {
  private ManagePrivateEndpointsUseCase usecase;

  this(ManagePrivateEndpointsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/private-endpoints",        &handleCreate);
    router.get("/api/v1/private-endpoints",         &handleList);
    router.get("/api/v1/private-endpoints/*",       &handleGet);
    router.put("/api/v1/private-endpoints/*",       &handleUpdate);
    router.delete_("/api/v1/private-endpoints/*",   &handleDelete);
    router.post("/api/v1/private-endpoints/*/approve", &handleApprove);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listEndpoints(tenantId);
    return successResponse("Private endpoints retrieved successfully", "Retrieved", 200, Json.emptyObject
        .set("items", items.map!(e => e.toJson).array.toJson)
        .set("totalCount", Json(items.length)));
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CreatePrivateEndpointRequest();
    r.tenantId = tenantId;
    r.serviceInstanceId = ServiceInstanceId(data.getString("serviceInstanceId"));

    r.name = data.getString("name");
    r.privateIpAddress = data.getString("privateIpAddress");
    r.hostname = data.getString("hostname");
    r.port = cast(ushort) j.getInt("port");
    r.iaasProvider = data.getString("iaasProvider");
    r.region = data.getString("region");
    r.providerEndpointId = data.getString("providerEndpointId");

    auto result = usecase.createEndpoint(r);
    if (result.hasError())
      return errorResponse(result.message, 400);

    return successResponse("Private endpoint created successfully", "Created", 201, Json.emptyObject
        .set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PrivateEndpointId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid private endpoint ID", 400);

    auto ep = usecase.getEndpoint(tenantId, id);
    if (ep.id.isNull)
      return errorResponse("Private endpoint not found", 404);

    return successResponse("Private endpoint retrieved successfully", "Retrieved", 200, ep.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PrivateEndpointId(precheck.id);
    auto data = precheck.data;
    auto r = UpdatePrivateEndpointStatusRequest();
    r.tenantId = tenantId;
    r.endpointId = id;
    r.status = data.getString("status");
    r.statusMessage = data.getString("statusMessage");

    auto result = usecase.updateEndpointStatus(r);
    if (result.hasError()) {
      auto code = result.message == "Private endpoint not found" ? 404 : 400;
      return errorResponse(result.message, code);
    }
    return successResponse("Endpoint status updated successfully", "Updated", 200, Json.emptyObject
        .set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PrivateEndpointId(precheck.id);
    
    auto result = usecase.deleteEndpoint(tenantId, id);
    if (result.hasError()) {
      auto code = result.message == "Private endpoint not found" ? 404 : 400;
      return errorResponse(result.message, code);
    }
    return successResponse("Private endpoint deleted successfully", "Deleted", 200, Json.emptyObject
        .set("id", result.id));
  }

  protected Json approveHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    // path: /api/v1/private-endpoints/<id>/approve
    auto path = req.requestURI;
    auto parts = path.split("/");
    string rawId;
    foreach (i, p; parts) {
      if (p == "approve" && i > 0)
        rawId = parts[i - 1];
    }
    auto id = PrivateEndpointId(rawId);
    auto data = precheck.data;
    auto r = ApprovePrivateEndpointRequest();
    r.tenantId = tenantId;
    r.endpointId = id;
    r.providerEndpointId = data.getString("providerEndpointId");
    r.privateIpAddress = data.getString("privateIpAddress");
    r.hostname = data.getString("hostname");
    r.port = cast(ushort) j.getInt("port");

    auto result = usecase.approveEndpoint(r);
    if (result.hasError()) {
      auto code = result.message == "Private endpoint not found" ? 404 : 400;
      return errorResponse(result.message, code);
    }
    return successResponse("Private endpoint approved successfully", "Approved", 200, Json.emptyObject
        .set("id", result.id));
  }

  mixin(HandleTemplate!("handleApprove", "approveHandler"));

}
