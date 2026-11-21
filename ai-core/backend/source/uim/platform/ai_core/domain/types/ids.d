/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers. TenantId and UserId come from uim-framework.
module uim.platform.ai_core.domain.types.ids;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct ResourceGroupId { mixin(IdTemplate); }
struct ScenarioId { mixin(IdTemplate); }
struct ExecutableId { mixin(IdTemplate); }
struct ConfigurationId { mixin(IdTemplate); }
struct ExecutionId { mixin(IdTemplate); }
struct DeploymentId { mixin(IdTemplate); }
struct ArtifactId { mixin(IdTemplate); }
struct ScheduleId { mixin(IdTemplate); }
struct MetricId { mixin(IdTemplate); }
struct DockerRegistrySecretId { mixin(IdTemplate); }
struct ObjectStoreSecretId { mixin(IdTemplate); }

/// A new identifier for server generated resources. AI API ids are
/// lowercase hex strings (16 characters), short enough for URLs and logs.
string newResourceId() @trusted {
  import std.uuid : randomUUID;
  import std.array : replace;

  return randomUUID().toString.replace("-", "")[0 .. 16];
}

///
unittest {
  auto a = newResourceId();
  assert(a.length == 16 && a != newResourceId());
  assert(ScenarioId("s").value == "s" && ScenarioId.init.isNull);
}
