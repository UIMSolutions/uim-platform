/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.business_subprocess;

import uim.platform.data.privacy.domain.types;

/// A business subprocess — a subset of a business process.
struct BusinessSubprocess {
  BusinessSubprocessId id;
  TenantId tenantId;
  BusinessProcessId parentProcessId;
  string name;
  string description;
  ProcessingPurpose[] purposes;
  PersonalDataCategory[] dataCategories;
  string owner;
  bool isActive = true;
  long createdAt;
  long updatedAt;
}
