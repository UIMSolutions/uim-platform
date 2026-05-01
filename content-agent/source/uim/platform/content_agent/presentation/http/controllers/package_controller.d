/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.presentation.http.controllers.package_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.content_agent.application.usecases.manage.content_packages;
// import uim.platform.content_agent.application.dto;
// import uim.platform.content_agent.domain.entities.content_package;
// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
class PackageController : PlatformController {
  private ManageContentPackagesUseCase uc;

  this(ManageContentPackagesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/packages", &handleCreate);
    router.get("/api/v1/packages", &handleList);
    router.get("/api/v1/packages/*", &handleGetById);
    router.put("/api/v1/packages/*", &handleUpdate);
    router.delete_("/api/v1/packages/*", &handleDelete);
    router.post("/api/v1/packages/assemble", &handleAssemble);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreatePackageRequest();
      r.tenantId = req.getTenantId;
      r.subaccountId = req.headers.get("X-Subaccount-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.version_ = j.getString("version");
      r.format = j.getString("format");
      r.tags = getStringArray(j, "tags");
      r.createdBy = req.headers.get("X-User-Id", "");
      r.items = parseContentItems(j);

      auto result = uc.createPackage(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Package created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto packages = uc.listPackages(tenantId);

      auto arr = Json.emptyArray;
      foreach (p; packages)
        arr ~= serializePackage(p);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(packages.length))
        .set("message", "Packages retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto pkg = uc.getPackage(id);
      if (pkg.isNull) {
        writeError(res, 404, "Package not found");
        return;
      }
      res.writeJsonBody(serializePackage(pkg), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdatePackageRequest();
      r.description = j.getString("description");
      r.version_ = j.getString("version");
      r.tags = getStringArray(j, "tags");
      r.items = parseContentItems(j);

      auto result = uc.updatePackage(id, r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Package updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Package not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deletePackage(id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("deleted", true)
          .set("message", "Package deleted successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleAssemble(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = AssemblePackageRequest();
      r.packageId = j.getString("packageId");
      r.tenantId = req.getTenantId;
      r.assembledBy = req.headers.get("X-User-Id", "");

      auto result = uc.assemblePackage(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("status", "assembled")
          .set("message", "Package assembled successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static ContentItem[] parseContentItems(Json j) {
    ContentItem[] items;
    auto v = "items" in j;
    if (v.isNull|| (*v).type != Json.Type.array)
      return items;

    foreach (itemJson; *v) {
      if (itemJson.type != Json.Type.object)
        continue;
      ContentItem item;
      item.id = itemJson.getString("id");
      item.name = itemJson.getString("name");
      item.providerId = itemJson.getString("providerId");
      item.version_ = itemJson.getString("version");
      item.description = itemJson.getString("description");
      item.dependencies = getStringArray(itemJson, "dependencies");

      auto catStr = itemJson.getString("category");
      item.category = parseContentCategory(catStr);
      items ~= item;
    }
    return items;
  }

  private static ContentCategory parseContentCategory(string s) {
    switch (s) {
    case "integrationFlow":
      return ContentCategory.integrationFlow;
    case "destination":
      return ContentCategory.destination;
    case "apiProxy":
      return ContentCategory.apiProxy;
    case "valueMapping":
      return ContentCategory.valueMapping;
    case "securityArtifact":
      return ContentCategory.securityArtifact;
    case "messageMapping":
      return ContentCategory.messageMapping;
    case "scriptCollection":
      return ContentCategory.scriptCollection;
    case "dataType":
      return ContentCategory.dataType;
    case "messageType":
      return ContentCategory.messageType;
    case "numberRange":
      return ContentCategory.numberRange;
    case "customForm":
      return ContentCategory.customForm;
    case "workflow":
      return ContentCategory.workflow;
    case "businessRule":
      return ContentCategory.businessRule;
    case "keyValueMap":
      return ContentCategory.keyValueMap;
    case "oauthCredential":
      return ContentCategory.oauthCredential;
    case "certificateToUserMapping":
      return ContentCategory.certificateToUserMapping;
    case "accessPolicy":
      return ContentCategory.accessPolicy;
    case "functionLibrary":
      return ContentCategory.functionLibrary;
    default:
      return ContentCategory.custom;
    }
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
