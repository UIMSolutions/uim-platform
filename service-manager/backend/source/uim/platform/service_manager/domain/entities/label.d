/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.label;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// Key/value metadata attached to a resource (for filtering and grouping).
struct Label {
  mixin TenantEntity!LabelId;

  ResourceType resourceType = ResourceType.serviceInstance;
  string resourceId;
  string key;
  string value;

  void validate() const {
    if (resourceId.strip.length == 0)
      throw ServiceManagerException.invalid("Label resourceId is required");
    if (!isValidLabelKey(key))
      throw ServiceManagerException.invalid(
        "Label key must be 1-63 characters of letters, digits, '.', '_', '-' or '/' and start with a letter or digit");
    if (value.length > 255)
      throw ServiceManagerException.invalid("Label value exceeds 255 characters");
  }
}
