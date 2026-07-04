/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_autoscaler.domain.entities.scaling_history;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// An immutable record of a scaling event triggered by the autoscaler.
struct ScalingHistory {
  mixin TenantEntity!ScalingHistoryId;

  AppBindingId appId;
  ScalingDirection direction;
  ScalingStatus status;
  string reason; // human-readable reason
  string message; // optional detail / error
  int oldInstances;
  int newInstances;
  long timestamp;

  Json toJson() const @safe {
    return entityToJson
    .set("app_id", appId)
    .set("direction", direction.to!string)
    .set("status", status.to!string)
    .set("reason", reason)
    .set("message", message)
    .set("old_instances", oldInstances)
    .set("new_instances", newInstances)
    .set("timestamp", timestamp);
  }
}
