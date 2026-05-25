/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.legal_ground;

// import uim.platform.data.privacy.application.usecases.manage.legal_grounds;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.legal_ground;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class LegalGroundController : ManageController {
  private ManageLegalGroundsUseCase usecase;

  this(ManageLegalGroundsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/legal-grounds", &handleCreate);
    router.get("/api/v1/legal-grounds", &handleList);
    router.get("/api/v1/legal-grounds/*", &handleGet);
    router.put("/api/v1/legal-grounds/*", &handleUpdate);
    router.delete_("/api/v1/legal-grounds/*", &handleDelete);
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateLegalGroundRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.basis = j.getString("basis").to!LegalBasis;
      r.purpose = j.getString("purpose");
      r.description = j.getString("description");
      r.legalReference = j.getString("legalReference");
      r.validFrom = j.getLong("validFrom");
      r.validUntil = j.getLong("validUntil");

      auto result = usecase.createGround(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Legal ground created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto basisParam = req.headers.get("X-Basis-Filter", "");
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      LegalGround[] items;
      if (basisParam.length > 0)
        items = usecase.listGrounds(tenantId, basisParam.toLegalBasis);
      else if (purposeParam.length > 0)
        items = usecase.listGrounds(tenantId, purposeParam.toProcessingPurpose);
      else if (subjectParam.length > 0)
        items = usecase.listGrounds(tenantId, DataSubjectId(subjectParam));
      else
        items = usecase.listGrounds(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Legal grounds retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = LegalGroundId(extractIdFromPath(req.requestURI));

      auto entry = usecase.getGround(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Legal ground not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      UpdateLegalGroundRequest r;
      r.id = LegalGroundId(extractIdFromPath(req.requestURI));
      r.tenantId = tenantId;
      r.description = j.getString("description");
      r.legalReference = j.getString("legalReference");
      r.isActive = j.getBoolean("isActive", true);
      r.validUntil = j.getLong("validUntil");

      auto result = usecase.updateGround(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Legal ground updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = LegalGroundId(extractIdFromPath(req.requestURI));

      usecase.deleteGround(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
