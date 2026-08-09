/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.services.analytics_validator;

import uim.platform.analytics.application.dto;

struct AnalyticsValidator {
  string validateCreate(CreateAssetRequest req) const {
    if (req.tenantId.length == 0) return "tenantId is required";
    if (req.name.isEmpty) return "name is required";
    if (req.kind.length == 0) return "kind is required";
    if (req.sourceSystem.length == 0) return "sourceSystem is required";
    return "";
  }

  string validateUpdate(UpdateAssetRequest req) const {
    if (req.tenantId.length == 0) return "tenantId is required";
    if (req.id.length == 0) return "id is required";
    if (req.name.isEmpty) return "name is required";
    if (req.kind.length == 0) return "kind is required";
    if (req.sourceSystem.length == 0) return "sourceSystem is required";
    return "";
  }
}
