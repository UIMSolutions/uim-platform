/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.medication_request;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

class MedicationRequestController : ManageHttpController {
  private ManageMedicationRequestsUseCase usecase;

  this(ManageMedicationRequestsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/fhir/R4/MedicationRequest", &handleList);
    router.get("/fhir/R4/MedicationRequest/*", &handleGet);
    router.post("/fhir/R4/MedicationRequest", &handleCreate);
    router.put("/fhir/R4/MedicationRequest/*", &handleUpdate);
    router.delete_("/fhir/R4/MedicationRequest/*", &handleDelete);
  }

  private static void writeFhirError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(
      Json.emptyObject.set("resourceType", "OperationOutcome")
        .set("issue", Json.emptyArray ~= Json.emptyObject
          .set("severity", "error").set("code", "processing").set("diagnostics", msg)),
        status
    );
  }

  private static MedicationRequestStatus parseStatus(string s) {
    switch (s) {
    case "active":
      return MedicationRequestStatus.active_;
    case "on-hold":
      return MedicationRequestStatus.onHold_;
    case "cancelled":
      return MedicationRequestStatus.cancelled_;
    case "completed":
      return MedicationRequestStatus.completed_;
    case "entered-in-error":
      return MedicationRequestStatus.enteredInError;
    case "stopped":
      return MedicationRequestStatus.stopped_;
    case "draft":
      return MedicationRequestStatus.draft_;
    default:
      return MedicationRequestStatus.unknown_;
    }
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateMedicationOrderRequest r;
    r.tenantId = tenantId;
    r.medicationRequestId = MedicationRequestId(precheck.id);
    r.status_ = toMedicationRequestStatus(data.getString("status"));
    r.authoredOn_ = data.getString("authoredOn");
    r.note_ = data.getString("note");
    auto subjJ = j.get("subject", Json.emptyObject);
    r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
    auto medJ = j.get("medicationReference", Json.emptyObject);
    r.medicationReference_ = FhirReference(medJ.getString("reference"), medJ.getString("display"));

    auto result = usecase.createMedicationRequest(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("resourceType", "MedicationRequest").set("id", result.id);
    return successResponse("MedicationRequest created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    MedicationRequest[] requests;
    auto patientParam = req.query.get("subject", "");
    if (patientParam.length > 0)
      requests = usecase.listByPatient(tenantId, patientParam);
    else
      requests = usecase.listMedicationRequests(tenantId);
    auto entries = Json.emptyArray;
    foreach (mr; requests)
      entries ~= mr.toJson();

    auto resp = Json.emptyObject
      .set("items", entries)
      .set("totalCount", requests.length);
    return successResponse("MedicationRequests retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MedicationRequestId(precheck.id);
    auto mr = usecase.getMedicationRequest(tenantId, id);
    if (mr.isNull) {
      writeFhirError(res, 404, "MedicationRequest not found");
      return;
    }
    res.writeJsonBody(mr.toJson(), 200);
  }
 catch (Exception e) {
  // writeFhirError(res, 500, "Internal server error");
  }
}

override protected Json updateHandler(HTTPServerRequest req) {
  auto precheck = super.updateHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = MedicationRequestId(precheck.id);
  auto data = precheck.data;
  UpdateMedicationOrderRequest r;
  r.tenantId = tenantId;
  r.medicationRequestId = id;
  r.status_ = toMedicationRequestStatus(data.getString("status"));
  r.authoredOn_ = data.getString("authoredOn");
  r.note_ = data.getString("note");
  auto subjJ = j.get("subject", Json.emptyObject);
  r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
  auto result = usecase.updateMedicationRequest(r);
  if (result.success)
    res.writeJsonBody(Json.emptyObject.set("resourceType", "MedicationRequest")
        .set("id", result.id), 200);
  else
    writeFhirError(res, 400, result.message);
}
 catch (Exception e) {
// writeFhirError(res, 500, "Internal server error");
}
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = MedicationRequestId(precheck.id);
  auto result = usecase.deleteMedicationRequest(tenantId, id);
  if (result.success)
    res.writeBody("", cast(int)HTTPStatus.noContent, "application/json");
  else
    writeFhirError(res, 404, result.message);
}
 catch (Exception e) {
// writeFhirError(res, 500, "Internal server error");
}
}
}
