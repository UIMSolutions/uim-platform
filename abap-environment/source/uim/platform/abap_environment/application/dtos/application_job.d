/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.dtos.application_job;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

struct CreateApplicationJobRequest {
  TenantId tenantId;
  SystemInstanceId systemInstanceId;
  
  string name;
  string description;
  string jobTemplateName;
  string frequency; // "once", "hourly", "daily", "weekly", "monthly"
  long scheduledAt;
  string cronExpression;
  string[string] jobParameters;

  Json toJson() const {
    auto jobParams = Json.emptyObject;
    foreach (key, value; jobParameters) {
      jobParams.set(key, value);
    }

    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("systemInstanceId", systemInstanceId.value)
      .set("name", name)
      .set("description", description)
      .set("jobTemplateName", jobTemplateName)
      .set("frequency", frequency)
      .set("scheduledAt", scheduledAt)
      .set("cronExpression", cronExpression)
      .set("jobParameters", jobParams);
  }
}

struct UpdateApplicationJobRequest {
  string description;
  string frequency;
  long scheduledAt;
  string cronExpression;
  bool active;
  string[string] jobParameters;

  Json toJson() const {
    auto jobParams = Json.emptyObject;
    foreach (key, value; jobParameters) {
      jobParams.set(key, value);
    }
    return Json.emptyObject
      .set("description", description)
      .set("frequency", frequency)
      .set("scheduledAt", scheduledAt)
      .set("cronExpression", cronExpression)
      .set("active", active)
      .set("jobParameters", jobParams);
  }
}
