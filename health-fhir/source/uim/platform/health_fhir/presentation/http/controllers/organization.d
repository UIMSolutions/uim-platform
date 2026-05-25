/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.organization;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class OrganizationController : ManageController {
  private ManageOrganizationsUseCase usecase;

  this(ManageOrganizationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Organization",     &handleList);
    router.get("/fhir/R4/Organization/*",   &handleGet);
    router.post("/fhir/R4/Organization",    &handleCreate);
    router.put("/fhir/R4/Organization/*",   &handleUpdate);
    router.delete_("/fhir/R4/Organization/*", &handleDelete);
  }

  private static void writeFhirError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(
      Json.emptyObject.set("resourceType", "OperationOutcome")
        .set("issue", Json.emptyArray ~= Json.emptyObject
          .set("severity", "error").set("code", "processing").set("diagnostics", msg)),
      status
    );
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateOrganizationRequest r;
      r.tenantId        = tenantId;
      r.organizationId  = OrganizationId(j.getString("id"));
      r.name_           = j.getString("name");
      r.active_         = j.get("active", Json(true)).get!bool;
      auto result = usecase.createOrganization(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Organization").set("id", result.id), 201);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto orgs = usecase.listOrganizations(tenantId);
      auto entries = Json.emptyArray;
      foreach (o; orgs) entries ~= o.toJson();
      res.writeJsonBody(
        Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
          .set("total", orgs.length).set("entry", entries),
        200
      );
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = OrganizationId(extractIdFromPath(req.requestURI.to!string));
      auto o = usecase.getOrganization(tenantId, id);
      if (o.isNull) { writeFhirError(res, 404, "Organization not found"); return; }
      res.writeJsonBody(o.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = OrganizationId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      UpdateOrganizationRequest r;
      r.tenantId = tenantId;
      r.organizationId = id;
      r.name_   = j.getString("name");
      r.active_ = j.get("active", Json(true)).get!bool;
      auto result = usecase.updateOrganization(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Organization").set("id", result.id), 200);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = OrganizationId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteOrganization(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }
}
