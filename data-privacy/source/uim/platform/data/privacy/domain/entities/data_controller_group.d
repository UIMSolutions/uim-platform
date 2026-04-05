/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.data_controller_group;

import uim.platform.data.privacy.domain.types;

/// A grouping of data controllers for organizational management.
struct DataControllerGroup {
  DataControllerGroupId id;
  TenantId tenantId;
  string name;
  string description;
  DataControllerId[] controllerIds;
  bool isActive = true;
  long createdAt;
  long updatedAt;
}
