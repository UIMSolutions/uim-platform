/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.controllers.tenant;

// import uim.platform.identity_authentication.application.usecases.manage.tenants;
// import uim.platform.identity_authentication.application.dto;
// import uim.platform.identity_authentication.domain.entities.tenant;
// import uim.platform.identity_authentication.domain.types;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// HTTP controller for tenant management.
class TenantController : ManageHttpController {
  private ManageTenantsUseCase useCase;

  this(ManageTenantsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/tenants", &handleCreate);
    router.get("/api/v1/tenants", &handleList);
    router.get("/api/v1/tenants/*", &handleGet);
    router.put("/api/v1/tenants/*", &handleUpdate);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreateTenantRequest(data.getString("name"),
      data.getString("subdomain"), SsoProtocol.oidc, [AuthMethod.form], false);

    auto result = useCase.createTenant(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject.set("id", result.id);
    return successResponse("Tenant created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto tenants = useCase.listTenants();
    auto response = Json.emptyObject;
    response["totalResults"] = Json(tenants.length);
    response["resources"] = toJsonArray(tenants);

    return successResponse("Tenants retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    // import std.string : lastIndexOf;

    auto path = req.requestURI;
    auto idx = path.lastIndexOf('/');
    TenantId tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

    auto tenant = useCase.getTenant(tenantId);
    if (tenant.isNull)
      return errorResponse("Tenant not found", 404);

    auto response = Json.emptyObject.set("id", tenant.id)
      .set("name", tenant.name)
      .set("subdomain", tenant.subdomain)
      .set("protocol", tenant.protocol.toString())
      .set("authMethods", tenant.authMethods.map!(m => m.toString())
          .array.toJson)
      .set("multiTenantEnabled", tenant.multiTenantEnabled);

    return successResponse("Tenant retrieved successfully", "Get", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    // import std.string : lastIndexOf;

    auto path = req.requestURI;
    auto idx = path.lastIndexOf('/');
    TenantId tenantId = idx >= 0 ? path[idx + 1 .. $] : "";

    auto data = precheck.data;
    auto updateReq = UpdateTenantRequest(tenantId, data.getString("name"), []);

    auto result = useCase.updateTenant(updateReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject.set("id", result.id);
    return successResponse("Tenant updated successfully", "Updated", 200, response);
  }
}
