/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.consent_record;

import uim.platform.data.privacy.domain.types;

/// A consent record — tracks a data subject's consent for a specific purpose.
struct ConsentRecord {
  ConsentRecordId id;
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  ProcessingPurpose purpose;
  PersonalDataCategory[] categories;
  ConsentStatus status = ConsentStatus.pending;
  string channel; // how consent was obtained: "web", "email", "paper"
  string consentText; // text the data subject agreed to
  string version_; // consent form version
  string ipAddress; // IP at time of consent (for proof)
  long grantedAt;
  long revokedAt;
  long expiresAt; // 0 = no expiry
  long createdAt;
}
