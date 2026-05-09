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
class BusinessSubprocessController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateBusinessSubprocessRequest r;
      r.tenantId = tenantId;
      r.parentProcessId = BusinessProcessId(j.getString("parentProcessId"));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purposes = getStrings(j, "purposes").map!(p => p.to!ProcessingPurpose).array;
      r.dataCategories = getStrings(j, "dataCategories").map!(c => c.to!DataCategoryId).array;
      r.owner = UserId(j.getString("owner"));

      auto result = usecase.createSubprocess(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Business subprocess created");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

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

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = BusinessSubprocessId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto entry = usecase.getSubprocess(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Business subprocess not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UpdateBusinessSubprocessRequest r;
      r.id = BusinessSubprocessId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purposes = getStrings(j, "purposes").map!(p => PurposeId(p)).array;
      r.dataCategories = getStrings(j, "dataCategories").map!(c => DataCategoryId(c)).array;
      r.owner = UserId(j.getString("owner"));

      auto result = usecase.updateSubprocess(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Business subprocess updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = BusinessSubprocessId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      usecase.deleteSubprocess(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const BusinessSubprocess e) {
    auto purps = e.purposes.map!(p => p.toJson).array.toJson;

    auto cats = e.dataCategories.map!(c => c.toJson).array.toJson;

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
