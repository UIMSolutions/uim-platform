/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.business_subprocess;
// import uim.platform.data.privacy.application.usecases.manage.business_subprocesses;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_subprocess;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class BusinessSubprocessController : ManageController {
  private ManageBusinessSubprocessesUseCase usecase;

  this(ManageBusinessSubprocessesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-subprocesses", &handleCreate);
    router.get("/api/v1/business-subprocesses", &handleList);
    router.get("/api/v1/business-subprocesses/*", &handleGet);
    router.put("/api/v1/business-subprocesses/*", &handleUpdate);
    router.delete_("/api/v1/business-subprocesses/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      CreateBusinessSubprocessRequest r;
      r.tenantId = tenantId;
      r.parentProcessId = BusinessProcessId(data.getString("parentProcessId"));
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.purposes = j.getStrings("purposes");
      r.dataCategories = j.getStrings("dataCategories");
      r.owner = data.getString("owner");

      auto result = usecase.createSubprocess(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Business subprocess created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;

      auto items = usecase.listSubprocesses(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Business subprocesses retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = BusinessSubprocessId(precheck.id);

      auto entry = usecase.getSubprocess(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Business subprocess not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;

      UpdateBusinessSubprocessRequest r;
      r.tenantId = tenantId;
      r.subprocessId = BusinessSubprocessId(precheck.id);
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.purposes = j.getStrings("purposes");
      r.dataCategories = j.getStrings("dataCategories");
      r.owner = data.getString("owner");

      auto result = usecase.updateSubprocess(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Business subprocess updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = BusinessSubprocessId(precheck.id);

      usecase.deleteSubprocess(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const BusinessSubprocess e) {
    auto purps = e.purposes.map!(p => p.to!string).array.toJson;

    auto cats = e.dataCategories.map!(c => c.to!string).array.toJson;

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("parentProcessId", e.parentProcessId)
      .set("name", e.name)
      .set("description", e.description)
      .set("owner", e.owner)
      .set("isActive", e.isActive)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt)
      .set("purposes", purps)
      .set("dataCategories", cats);
  }
}
