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
  mixin(IdTemplate);
}

struct DevSpaceId {
  mixin(IdTemplate);
}

struct TemplateId {
  mixin(IdTemplate);
}

struct PipelineId {
  mixin(IdTemplate);
}

struct BuildJobId {
  mixin(IdTemplate);
}

struct DeploymentId {
  mixin(IdTemplate);
}

struct AIRequestId {
  mixin(IdTemplate);
}

