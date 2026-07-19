/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.package_;

// import uim.platform.content_agent.application.usecases.manage.content_packages;

// import uim.platform.content_agent.domain.entities.content_package;

import uim.platform.content_agent;
mixin(ShowModule!());

@safe:
class PackageController : ManageHttpController {
  private ManageContentPackagesUseCase usecase;

  this(ManageContentPackagesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/packages", &handleCreate);
    router.get("/api/v1/packages", &handleList);
    router.get("/api/v1/packages/*", &handleGet);
    router.put("/api/v1/packages/*", &handleUpdate);
    router.delete_("/api/v1/packages/*", &handleDelete);
    router.post("/api/v1/packages/assemble", &handleAssemble);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreatePackageRequest();
    r.tenantId = tenantId;
    r.subaccountId = req.headers.get("X-Subaccount-Id", "");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.version_ = data.getString("version");
    r.format = data.getString("format");
    r.tags = data.getStrings("tags");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));
    r.items = parseContentItems(j);

    auto result = usecase.createPackage(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Package created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto packages = usecase.listPackages(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Packages retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ContentPackageId(precheck.id);
    auto pkg = usecase.getPackage(tenantId, id);
    if (pkg.isNull)
      return errorResponse("Package not found", 404);

    auto responseData = pkg.toJson();
    return successResponse("Package retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ContentPackageId(precheck.id);
    auto data = precheck.data;
    auto r = UpdatePackageRequest();
    r.tenantId = tenantId;
    r.description = data.getString("description");
    r.version_ = data.getString("version");
    r.tags = data.getStrings("tags");
    r.items = parseContentItems(j);

    auto result = usecase.updatePackage(id, r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Package updated successfully", "Updated", 200, responseData);

  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ContentPackageId(precheck.id);
    auto result = usecase.deletePackage(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Package deleted successfully", "Deleted", 200, responseData);
  }

  protected Json assembleHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = AssemblePackageRequest();
    r.packageId = ContentPackageId(data.getString("packageId"));
    r.tenantId = tenantId;
    r.assembledBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.assemblePackage(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Package assembled successfully", "Assembled", 200, responseData);
  }

  mixin(HandleTemplate!("handleAssemble", "assembleHandler"));

  private static ContentItem[] parseContentItems(Json j) {
    ContentItem[] items;

    foreach (itemJson; data.getArray("items")) {
      if (!itemJson.isObject)
        continue;
      ContentItem item;
      item.id = itemJson.getString("id");
      item.name = itemJson.getString("name");
      item.providerId = itemJson.getString("providerId");
      item.version_ = itemJson.getString("version");
      item.description = itemJson.getString("description");
      item.dependencies = getStrings(itemJson, "dependencies");
      item.category = itemJson.getString("category").to!ContentCategory;
      items ~= item;
    }

    return items;
  }
}
