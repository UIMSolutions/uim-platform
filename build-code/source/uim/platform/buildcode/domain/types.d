/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.types;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

// ── ID types ─────────────────────────────────────────────────────────────────
struct ProjectId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}

struct DevSpaceId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}

struct TemplateId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}

struct PipelineId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}

struct BuildJobId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}

struct DeploymentId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}

struct AIRequestId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}

struct ServiceBindingId {
  string value;
  this(string v) {
    value = v;
  }

  mixin IdTemplate;
}
