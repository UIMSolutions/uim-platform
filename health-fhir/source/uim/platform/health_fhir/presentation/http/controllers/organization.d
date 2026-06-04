/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.organization;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class OrganizationController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = precheck.tenantId;
      CreateOrganizationRequest r;
      r.tenantId        = tenantId;
      r.organizationId  = OrganizationId(precheck.id);
      r.name_           = data.getString("name");
      r.active_         = j.get("active", Json(true)).get!bool;
      auto result = usecase.createOrganization(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Organization created successfully", "Created", 201, responseData);
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
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

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = OrganizationId(precheck.id);
      auto o = usecase.getOrganization(tenantId, id);
      if (o.isNull) { writeFhirError(res, 404, "Organization not found"); return; }
      res.writeJsonBody(o.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = OrganizationId(precheck.id);
      auto data = precheck.data;
      UpdateOrganizationRequest r;
      r.tenantId = precheck.tenantId;
      r.organizationId = id;
      r.name_   = data.getString("name");
      r.active_ = j.get("active", Json(true)).get!bool;
      auto result = usecase.updateOrganization(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Organization updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = OrganizationId(precheck.id);
      if (id.isNull) 
        return errorResponse("Invalid organization ID", 400);

      auto result = usecase.deleteOrganization(tenantId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Organization deleted successfully", "Deleted", 200, responseData);
  }
}
