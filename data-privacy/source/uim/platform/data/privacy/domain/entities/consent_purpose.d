/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.consent_purpose;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A consent purpose configuration — templated consent form for a business process.
struct ConsentPurpose {
  mixin TenantEntity!(ConsentPurposeId);

  DataControllerId controllerId;
  string name;
  string description;
  ProcessingPurpose purpose;
  PersonalDataCategory[] dataCategories;
  ConsentPurposeStatus status = ConsentPurposeStatus.draft;
  string consentFormTemplate; // templated text for the consent form
  string version_;
  bool requiresExplicitConsent;
  long validFrom;
  long validUntil; // 0 = indefinite

  Json toJson() const {
      return entityToJson
          .set("controllerId", controllerId.value)
          .set("name", name)
          .set("description", description)
          .set("purpose", purpose.to!string)
          .set("dataCategories", dataCategories.map!(dc => dc.to!string).array)
          .set("status", status.to!string)
          .set("consentFormTemplate", consentFormTemplate)
          .set("version", version_)
          .set("requiresExplicitConsent", requiresExplicitConsent)
          .set("validFrom", validFrom)
          .set("validUntil", validUntil);
  }
}
