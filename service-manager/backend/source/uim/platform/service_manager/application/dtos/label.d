/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.dtos.label;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct CreateLabelRequest {
  TenantId tenantId;
  UserId actor;
  string id;

  string resourceType;
  string resourceId;
  string key;
  string value;
}

struct UpdateLabelRequest {
  TenantId tenantId;
  UserId actor;
  LabelId id;

  Patch!string value;
}
