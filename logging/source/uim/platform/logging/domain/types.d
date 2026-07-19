/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.types;
import uim.platform.logging;
mixin(ShowModule!());

@safe:
struct LogEntryId {
  mixin(IdTemplate);
}

struct LogStreamId {
  mixin(IdTemplate);
}

struct TraceId {
  mixin(IdTemplate);
}

struct SpanId {
  mixin(IdTemplate);
}

struct DashboardId {
  mixin(IdTemplate);
}

struct PanelId {
  mixin(IdTemplate);
}

struct RetentionPolicyId {
  mixin(IdTemplate);
}

struct AlertRuleId {
  mixin(IdTemplate);
}

struct AlertId {
  mixin(IdTemplate);
}

struct NotificationChannelId {
  mixin(IdTemplate);
}

struct PipelineId {
  mixin(IdTemplate);
}
struct IngestionTokenId {
    mixin(IdTemplate);
}
// struct  {
//       mixin(IdTemplate);

// }
// struct  {
//       mixin(IdTemplate);

// }

