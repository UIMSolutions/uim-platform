/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.deletion_request;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A request to erase personal data for a data subject (GDPR Art. 17).
struct DeletionRequest {
  DeletionRequestId id;
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy; // DPO or the data subject themselves
  RequestType requestType = RequestType.deletion;
  DeletionStatus status = DeletionStatus.requested;
  string[] targetSystems; // systems where data should be deleted
  PersonalDataCategory[] categories; // categories to delete (empty = all)
  string reason; // justification/legal basis
  string blockerReason; // if status == blocked, why
  long requestedAt;
  long completedAt;
  long deadline; // regulatory deadline (e.g. 30 days)
}
