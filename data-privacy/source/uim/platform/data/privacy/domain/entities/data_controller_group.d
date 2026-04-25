/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.data_controller_group;

// import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// A grouping of data controllers for organizational management.
struct DataControllerGroup {
  mixin TenantEntity!(DataControllerGroupId);

  string name;
  string description;
  DataControllerId[] controllerIds;
  bool isActive = true;
 
  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("controllerIds", controllerIds.map!(id => id.value).array);

  }
}
