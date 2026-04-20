/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.data_controller;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A data controller — the legal entity responsible for data protection compliance.
struct DataController {
  mixin TenantEntity!(DataControllerId);

  string name;
  string description;
  string legalEntityName;
  string contactEmail;
  string contactPhone;
  string address;
  string country; // ISO 3166-1 alpha-2
  string dpoName; // Data Protection Officer
  string dpoEmail;
  bool isActive = true;

  Json toJson() const {
      return entityToJson
          .set("name", name)
          .set("description", description)
          .set("legalEntityName", legalEntityName)
          .set("contactEmail", contactEmail)
          .set("contactPhone", contactPhone)
          .set("address", address)
          .set("country", country)
          .set("dpoName", dpoName)
          .set("dpoEmail", dpoEmail)
          .set("isActive", isActive)
          .set("createdAt", createdAt)
          .set("updatedAt", updatedAt);
  }
}
