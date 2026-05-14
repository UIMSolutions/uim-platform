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
struct ScalingHistoryEntity {
  ScalingHistoryId id;
  AppBindingId     appId;
  TenantId         tenantId;
  ScalingDirection direction;
  ScalingStatus    status;
  string           reason;         // human-readable reason
  string           message;        // optional detail / error
  int              oldInstances;
  int              newInstances;
  long             timestamp;

  Json toJson() const @safe {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"]            = Json(id);
    j["app_id"]        = Json(appId);
    j["tenant_id"]     = Json(tenantId);
    j["direction"]     = Json(direction.to!string);
    j["status"]        = Json(status.to!string);
    j["reason"]        = Json(reason);
    j["message"]       = Json(message);
    j["old_instances"] = Json(oldInstances);
    j["new_instances"] = Json(newInstances);
    j["timestamp"]     = Json(timestamp);
    return j;
  }
}
