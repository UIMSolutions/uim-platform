/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.blocking_request;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A request to restrict processing of personal data (GDPR Art. 18).
struct BlockingRequest {
  mixin TenantEntity!(BlockingRequestId);

  DataSubjectId dataSubjectId;
  UserId requestedBy;
  BlockingStatus status = BlockingStatus.requested;
  string[] targetSystems;
  PersonalDataCategory[] categories;
  string reason;
  long requestedAt;
  long activatedAt;
  long releasedAt;

  Json toJson() const {
    return entityToJson
      .set("dataSubjectId", dataSubjectId)
      .set("requestedBy", requestedBy)
      .set("status", status.to!string)
      .set("targetSystems", targetSystems)
      .set("categories", categories.map!(c => c.to!string))
      .set("reason", reason)
      .set("requestedAt", requestedAt)
      .set("activatedAt", activatedAt)
      .set("releasedAt", releasedAt);

  }
}
