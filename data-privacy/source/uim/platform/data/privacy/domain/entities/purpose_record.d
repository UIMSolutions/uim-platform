/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.purpose_record;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A purpose record — tracks a specific purpose with retention/residence and expiration.
struct PurposeRecord {
  mixin TenantEntity!(PurposeRecordId);

  DataSubjectId dataSubjectId;
  BusinessContextId businessContextId;
  ProcessingPurpose purpose;
  PurposeRecordStatus status = PurposeRecordStatus.active;
  LegalBasis legalBasis;
  int residenceDays; // how long data resides before blocking
  int retentionDays; // how long blocked data is retained before destruction
  long validFrom;
  long validUntil; // 0 = indefinite
  long deactivatedAt;

  Json toJson() const {
    return entityToJson
      .set("dataSubjectId", dataSubjectId)
      .set("businessContextId", businessContextId)
      .set("purpose", purpose)
      .set("status", status.to!string)
      .set("legalBasis", legalBasis)
      .set("residenceDays", residenceDays)
      .set("retentionDays", retentionDays)
      .set("validFrom", validFrom)
      .set("validUntil", validUntil)
      .set("deactivatedAt", deactivatedAt);
  }
}
