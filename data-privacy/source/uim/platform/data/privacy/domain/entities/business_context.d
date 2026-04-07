/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.business_context;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A business context — defines the context for processing personal data with versioning.
struct BusinessContext {
  BusinessContextId id;
  TenantId tenantId;
  string name;
  string description;
  DataControllerGroupId controllerGroupId;
  BusinessContextStatus status = BusinessContextStatus.draft;
  int version_ = 1;
  PersonalDataCategory[] dataCategories;
  ProcessingPurpose[] purposes;
  string[] dataCategoryAttributes; // fine-grained attribute mapping
  bool isCrossRoleEnabled; // sap:pdm-data-subject-cross-role-enabled
  long createdAt;
  long updatedAt;
  long activatedAt;
}
