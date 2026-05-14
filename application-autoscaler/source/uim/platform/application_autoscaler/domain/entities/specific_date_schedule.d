/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.specific_date_schedule;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// A one-time specific-date schedule entry.
struct SpecificDateScheduleEntity {
  SpecificDateScheduleId id;
  string startDateTime;        // YYYY-MM-DDTHH:MM
  string endDateTime;          // YYYY-MM-DDTHH:MM
  int    instanceMinCount;
  int    instanceMaxCount;
  int    initialMinInstanceCount;

  Json toJson() const @safe {
    auto j = Json.emptyObject;
    j["id"]                         = Json(id);
    j["start_date_time"]            = Json(startDateTime);
    j["end_date_time"]              = Json(endDateTime);
    j["instance_min_count"]         = Json(instanceMinCount);
    j["instance_max_count"]         = Json(instanceMaxCount);
    j["initial_min_instance_count"] = Json(initialMinInstanceCount);
    return j;
  }
}
