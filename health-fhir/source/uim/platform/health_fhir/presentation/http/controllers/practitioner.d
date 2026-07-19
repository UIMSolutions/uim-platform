/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.practitioner;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class PractitionerController : ManageHttpController {
  private ManagePractitionersUseCase usecase;

  this(ManagePractitionersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.get("/fhir/R4/Practitioner", &handleList);
    router.get("/fhir/R4/Practitioner/*", &handleGet);
    router.post("/fhir/R4/Practitioner", &handleCreate);
    router.put("/fhir/R4/Practitioner/*", &handleUpdate);
    router.delete_("/fhir/R4/Practitioner/*", &handleDelete);
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
    CreatePractitionerRequest r;
    r.tenantId = tenantId;
    r.practitionerId = PractitionerId(precheck.id);
    r.birthDate_ = data.getString("birthDate");
    r.active_ = data.get("active", Json(true)).get!bool;

    auto result = usecase.createPractitioner(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Practitioner created successfully", 201, Json.emptyObject.set("resourceType", "Practitioner")
        .set("id", result.id));
    //   res.writeJsonBody(Json.emptyObject.set("resourceType", "Practitioner")
    //       .set("id", result.id), 201);
    // else
    //   writeFhirError(res, 400, result.message);

  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto practitioners = usecase.listPractitioners(tenantId);
    auto entries = practitioners.map!(p => p.toJson).array.toJson;

    // res.writeJsonBody(
    //   Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
    //     .set("total", practitioners.length).set("entry", entries),
    //     200
    // );

    auto responseData = Json.emptyObject
      .set("resourceType", "Bundle")
      .set("type", "searchset")
      .set("total", practitioners.length).set("entry", entries);
    return successResponse("Practitioners retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PractitionerId(precheck.id);
    auto p = usecase.getPractitioner(tenantId, id);
    if (p.isNull)
      return errorResponse("Practitioner not found", 404);

    auto responseData = p.toJson;
    return successResponse("Practitioner retrieved successfully", "Retrieved", 200, responseData);
    // writeFhirError(res, 404, "Practitioner not found");
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PractitionerId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid practitioner ID", 400);
    // { writeFhirError(res, 400, "Invalid practitioner ID"); return; }

    auto data = precheck.data;
    UpdatePractitionerRequest r;
    r.tenantId = tenantId;
    r.practitionerId = id;
    r.birthDate_ = data.getString("birthDate");
    r.active_ = data.get("active", Json(true)).get!bool;
    auto result = usecase.updatePractitioner(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Practitioner updated successfully", "Updated", 200, Json.emptyObject.set(
        "resourceType", "Practitioner")
        .set("id", result.id));

    //   res.writeJsonBody(Json.emptyObject.set("resourceType", "Practitioner")
    //       .set("id", result.id), 200);
    // else
    //   writeFhirError(res, 400, result.message);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PractitionerId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid practitioner ID", 400);

    auto result = usecase.deletePractitioner(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Practitioner deleted successfully", "Deleted", 204, Json.emptyObject);
    //   res.writeBody("", cast(int)HTTPStatus.noContent, "application/json");
    // else
    //   writeFhirError(res, 404, result.message);
  }
}
