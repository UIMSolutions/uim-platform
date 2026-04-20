/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.archive_request;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A request to archive personal and transactional data.
struct ArchiveRequest {
  mixin TenantEntity!(ArchiveRequestId);

  DataSubjectId dataSubjectId;
  UserId requestedBy;
  ArchiveStatus status = ArchiveStatus.scheduled;
  string[] targetSystems;
  PersonalDataCategory[] categories;
  string archiveLocation; // where data is archived to
  string reason;
  bool isTestMode; // test mode vs production mode
  long scheduledAt; // 0 = immediate
  long startedAt;
  long completedAt;

  Json toJson() const {
      auto j = entityToJson
          .set("dataSubjectId", dataSubjectId)
          .set("requestedBy", requestedBy)
          .set("status", status.to!string)
          .set("targetSystems", targetSystems)
          .set("categories", categories.map!(c => c.to!string))
          .set("archiveLocation", archiveLocation)
          .set("reason", reason)
          .set("isTestMode", isTestMode)
          .set("scheduledAt", scheduledAt)
          .set("startedAt", startedAt)
          .set("completedAt", completedAt);

      return j;
  }
}
