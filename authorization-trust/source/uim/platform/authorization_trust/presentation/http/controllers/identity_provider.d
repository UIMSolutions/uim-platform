/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.identity_provider;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class IdentityProviderController : ManageController {
  private ManageIdentityProvidersUseCase usecase;

  this(ManageIdentityProvidersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/identity-providers", &handleCreate);
    router.get("/api/v1/identity-providers", &handleList);
    router.get("/api/v1/identity-providers/*", &handleGet);
    router.put("/api/v1/identity-providers/*", &handleUpdate);
    router.delete_("/api/v1/identity-providers/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto idps = usecase.listIdentityProviders(tenantId);
    auto jarr = idps.map!(idp => idp.toJson()).array.toJson;

    Json.emptyObject
      .set("items", jarr)
      .set("totalCount", idps.length);

    return successResponse("Identity provider list retrieved successfully", "Retrieved", 200);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateIdentityProviderRequest r;
    r.tenantId = tenantId;
    r.alias_ = data.getString("alias");
    r.displayName = data.getString("displayName");
    r.idpType = data.getString("idpType");
    r.metadataUrl = data.getString("metadataUrl");
    r.entityId = data.getString("entityId");
    r.ssoUrl = data.getString("ssoUrl");
    r.sloUrl = data.getString("sloUrl");
    r.signingCert = data.getString("signingCert");
    r.isActive = data.getBoolean("isActive");
    r.isDefault = data.getBoolean("isDefault");

    auto result = usecase.createIdentityProvider(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject
      .set("id", result.id);

    return successResponse("Identity provider created successfully", "Created", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = IdentityProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid identity provider ID", 400);

    auto idp = usecase.getIdentityProvider(tenantId, id);
    if (idp.isNull)
      return errorResponse("Identity provider not found", 404);

    auto responseData = idp.toJson();
    return successResponse("Identity provider retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;
    auto data = precheck.data;

    auto id = IdentityProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid identity provider ID", 400);

    UpdateIdentityProviderRequest r;
    r.tenantId = tenantId;
    r.identityProviderId = id;
    r.displayName = data.getString("displayName");
    r.metadataUrl = data.getString("metadataUrl");
    r.ssoUrl = data.getString("ssoUrl");
    r.sloUrl = data.getString("sloUrl");
    r.signingCert = data.getString("signingCert");
    r.isActive = data.getBoolean("isActive");
    r.isDefault = data.getBoolean("isDefault");

    auto result = usecase.updateIdentityProvider(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Identity provider updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto path = precheck.path;

    auto id = IdentityProviderId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid identity provider ID", 400);

    auto result = usecase.deleteIdentityProvider(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Identity provider deleted successfully", "Deleted", 200, responseData);
  }
}
