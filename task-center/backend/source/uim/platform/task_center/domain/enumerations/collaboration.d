/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.domain.enumerations.collaboration;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// Stored status of a substitution rule (set by its owner). The effective
/// status additionally knows pending (before startDate) and expired (after endDate).
enum SubstitutionStatus : string {
  active = "active",
  inactive = "inactive",
  pending = "pending",
  expired = "expired"
}

enum AttachmentStatus : string {
  uploaded = "uploaded",
  processing = "processing",
  available = "available",
  deleted = "deleted"
}

/// Criterion of a saved inbox filter (maps onto a Task property).
enum FilterCriterionType : string {
  status = "status",
  priority = "priority",
  provider = "provider",
  category = "category",
  dueDate = "dueDate",
  assignee = "assignee",
  creator = "creator",
  taskDefinition = "taskDefinition"
}
