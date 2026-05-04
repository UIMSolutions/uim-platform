/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.correction_request;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A request to correct personal data for a data subject (GDPR Art. 16).
struct CorrectionRequest {
  mixin TenantEntity!(CorrectionRequestId);

  DataSubjectId dataSubjectId;
  UserId requestedBy;
  CorrectionStatus status = CorrectionStatus.requested;
  string[] targetSystems;
  string fieldName; // field to correct
  string currentValue; // existing value description
  string correctedValue; // requested correction
  string reason;
  long requestedAt;
  long completedAt;
  long deadline; // regulatory deadline

  Json toJson() const {
    return entityToJson
      .set("dataSubjectId", dataSubjectId)
      .set("requestedBy", requestedBy)
      .set("status", status.to!string)
      .set("targetSystems", targetSystems)
      .set("fieldName", fieldName)
      .set("currentValue", currentValue)
      .set("correctedValue", correctedValue)
      .set("reason", reason)
      .set("requestedAt", requestedAt)
      .set("completedAt", completedAt)
      .set("deadline", deadline);
  }
}
