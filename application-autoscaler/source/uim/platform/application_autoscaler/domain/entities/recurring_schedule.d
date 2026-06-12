/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.recurring_schedule;

import uim.platform.application_autoscaler;

// mixin(ShowModule!());

@safe:

/// A recurring (weekly/monthly) schedule entry.
struct RecurringScheduleEntity {
  RecurringScheduleId id;
  long startTime; // 
  long endTime; // HH:MM 24hr
  string startDate; // YYYY-MM-DD (optional)
  string endDate; // YYYY-MM-DD (optional)
  int[] daysOfWeek; // 1=Mon..7=Sun (mutually exclusive with daysOfMonth)
  int[] daysOfMonth; // 1..31
  int instanceMinCount;
  int instanceMaxCount;
  int initialMinInstanceCount;

  Json toJson() const @safe {
    auto j = Json.emptyObject;
    j["id"] = Json(id);
    j["start_time"] = Json(startTime);
    j["end_time"] = Json(endTime);
    j["start_date"] = Json(startDate);
    j["end_date"] = Json(endDate);
    j["instance_min_count"] = Json(instanceMinCount);
    j["instance_max_count"] = Json(instanceMaxCount);
    j["initial_min_instance_count"] = Json(initialMinInstanceCount);
    j["days_of_week"] = daysOfWeek.map!(d => d.toJson).array.toJson;
    j["days_of_month"] = daysOfMonth.map!(d => d.toJson).array.toJson;
    return j;
  }
}
