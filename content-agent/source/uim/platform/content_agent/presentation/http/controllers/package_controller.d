/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.package_controller;




// import uim.platform.content_agent.application.usecases.manage.content_packages;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.content_package;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class PackageController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = CreatePackageRequest();
      r.tenantId = tenantId;
      r.subaccountId = req.headers.get("X-Subaccount-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.version_ = j.getString("version");
      r.format = j.getString("format");
      r.tags = getStrings(j, "tags");
      r.createdBy = UserId(req.headers.get("X-User-Id", ""));
      r.items = parseContentItems(j);

      auto result = usecase.createPackage(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Package created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto packages = usecase.listPackages(tenantId);

      auto arr = packages.map!(p => p.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(packages.length))
        .set("message", "Packages retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = PackageId(extractIdFromPath(req.requestURI));
      auto pkg = usecase.getPackage(id);
      if (pkg.isNull) {
        writeError(res, 404, "Package not found");
        return;
      }
      auto resp = pkg.toJson()
        .set("message", "Package retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = PackageId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdatePackageRequest();
      r.description = j.getString("description");
      r.version_ = j.getString("version");
      r.tags = getStrings(j, "tags");
      r.items = parseContentItems(j);

      auto result = usecase.updatePackage(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Package updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.errorMessage == "Package not found" ? 404 : 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = PackageId(extractIdFromPath(req.requestURI));
      auto result = usecase.deletePackage(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Package deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleAssemble(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto r = AssemblePackageRequest();
      r.packageId = j.getString("packageId");
      r.tenantId = tenantId;
      r.assembledBy = UserId(req.headers.get("X-User-Id", ""));

      auto result = usecase.assemblePackage(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "assembled")
          .set("message", "Package assembled successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.errorMessage);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static ContentItem[] parseContentItems(Json j) {
    ContentItem[] items;

    foreach (itemJson; j.getArray("items")) {
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

  private static Json serializePackage(const ContentPackage p) {
    auto j = Json.emptyObject
      .set("id", p.id)
      .set("tenantId", p.tenantId)
      .set("subaccountId", p.subaccountId)
      .set("name", p.name)
      .set("description", p.description)
      .set("version", p.version_)
      .set("status", p.status.to!string)
      .set("format", p.format.to!string)
      .set("createdBy", p.createdBy)
      .set("createdAt", p.createdAt)
      .set("updatedAt", p.updatedAt)
      .set("assembledAt", p.assembledAt)
      .set("packageSizeBytes", p.packageSizeBytes);

    if (p.items.length > 0) {
      auto arr = Json.emptyArray;
      foreach (item; p.items) {
        arr ~= Json.emptyObject
          .set("id", item.id)
          .set("name", item.name)
          .set("category", item.category.to!string)
          .set("providerId", item.providerId)
          .set("version", item.version_)
          .set("description", item.description)
          .set("dependencies", item.dependencies);
      }
      j["items"] = arr;
    }

    if (p.tags.length > 0)
      j["tags"] = toJsonArray(p.tags);

    return j;
  }
}
