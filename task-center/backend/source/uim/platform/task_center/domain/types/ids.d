/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers. TenantId and UserId come from uim-framework.
module uim.platform.task_center.domain.types.ids;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

struct TaskId { mixin(IdTemplate); }
struct TaskDefinitionId { mixin(IdTemplate); }
struct TaskProviderId { mixin(IdTemplate); }
struct TaskCommentId { mixin(IdTemplate); }
struct TaskAttachmentId { mixin(IdTemplate); }
struct TaskActionId { mixin(IdTemplate); }
struct SubstitutionRuleId { mixin(IdTemplate); }
struct UserTaskFilterId { mixin(IdTemplate); }

/// A new random identifier (UUID v4).
string newResourceId() @trusted {
  import std.uuid : randomUUID;

  return randomUUID().toString;
}

///
unittest {
  assert(newResourceId().length == 36);
  assert(newResourceId() != newResourceId());
  assert(TaskId("t").value == "t" && TaskId.init.isNull);
}
