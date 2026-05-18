/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.entities.service_binding;

import uim.platform.buildcode;
import std.conv : to;

mixin(ShowModule!());

@safe:

/// A binding of an external BTP service to a project
struct ServiceBinding {
  mixin TenantEntity!(ServiceBindingId);

  ProjectId      projectId;
  string         serviceName;
  string         servicePlan;
  string         bindingLabel;
  BindingStatus  status;
  string         instanceId;
  string         credentials;   // JSON-serialised (stored as opaque string)

  Json toJson() const {
    auto j = entityToJson();
    j["projectId"]    = Json(projectId.value);
    j["serviceName"]  = Json(serviceName);
    j["servicePlan"]  = Json(servicePlan);
    j["bindingLabel"] = Json(bindingLabel);
    j["status"]       = Json(status.to!string);
    j["instanceId"]   = Json(instanceId);
    // credentials intentionally omitted from public JSON for security
    return j;
  }
}
