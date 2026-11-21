/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An artifact is a registered dataset, model or result set, referenced by
/// URL (ai://<object store secret>/<path> or any URL of an object store).
module uim.platform.ai_core.domain.entities.artifact;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Artifact {
  mixin TenantEntity!ArtifactId;

  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutionId executionId; /// producing execution ("" if registered manually)
  string name;
  ArtifactKind kind = ArtifactKind.other;
  string url;
  string description;
  Label[] labels;

  void validate() const {
    requireText(name, "Artifact name");
    requireMaxLength(name, 256, "Artifact name");
    requireText(scenarioId.value, "Scenario ID");
    if (!isArtifactUrl(url))
      throw AiCoreException.invalid("Artifact URL '" ~ url ~ "' must start with ai://, s3://, gs://, https:// or http://");
  }
}

bool isArtifactUrl(string url) pure {
  foreach (prefix; ["ai://", "s3://", "gs://", "wasbs://", "webhdfs://", "https://", "http://"])
    if (url.startsWith(prefix) && url.length > prefix.length)
      return true;
  return false;
}

///
unittest {
  assert(isArtifactUrl("ai://default/data/train.csv") && !isArtifactUrl("ai://") && !isArtifactUrl("/tmp/x"));
}
