/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.queue;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Put a transport request into the import queue of a node.
struct EnqueueInput {
  TenantId tenantId;
  string id;
  string nodeId;
  string requestId;
  int queuePosition; /// 0 = append at the end
  bool isSelected = true;
  long scheduledAt;
  UserId createdBy;
}
