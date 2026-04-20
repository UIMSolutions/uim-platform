/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.business_subprocess;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A business subprocess — a subset of a business process.
struct BusinessSubprocess {
  mixin TenantEntity!(BusinessSubprocessId);

  BusinessProcessId parentProcessId;
  string name;
  string description;
  ProcessingPurpose[] purposes;
  PersonalDataCategory[] dataCategories;
  string owner;
  bool isActive = true;
  
  Json toJson() const {
    auto j = entityToJson
      .set("parentProcessId", parentProcessId)
      .set("name", name)
      .set("description", description)
      .set("purposes", purposes)
      .set("dataCategories", dataCategories)
      .set("owner", owner)
      .set("isActive", isActive);

    return j;
  }
}
