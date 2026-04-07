/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.business_process;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A business process — a set of activities performed to achieve a business goal.
struct BusinessProcess {
  BusinessProcessId id;
  TenantId tenantId;
  string name;
  string description;
  DataControllerId controllerId;
  ProcessingPurpose[] purposes;
  LegalBasis[] legalBases;
  string owner; // responsible person
  bool isActive = true;
  long createdAt;
  long updatedAt;
}
