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
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct LogStreamId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct TraceId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct SpanId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct DashboardId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct PanelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct RetentionPolicyId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AlertRuleId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct AlertId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct NotificationChannelId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}

struct PipelineId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin IdTemplate;
}
struct IngestionTokenId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
// struct  {
//     string value;
//     this(string value) {
//         this.value = value;
//     }
//     mixin IdTemplate;
// }
// struct  {
//     string value;
//     this(string value) {
//         this.value = value;
//     }
//     mixin IdTemplate;
// }

