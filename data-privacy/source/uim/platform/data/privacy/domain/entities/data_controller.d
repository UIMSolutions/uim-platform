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
  DataControllerId id;
  TenantId tenantId;
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
  long createdAt;
  long updatedAt;
}
