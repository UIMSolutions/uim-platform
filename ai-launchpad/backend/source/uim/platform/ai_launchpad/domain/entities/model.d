/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A trained model in the registry (name + version unique per scenario),
/// optionally produced by a completed execution.
module uim.platform.ai_launchpad.domain.entities.model;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Model {
  mixin TenantEntity!ModelId;

  ScenarioId scenarioId;
  string executionId; /// producing execution ("" = imported)
  string name;
  string version_ = "1";
  string description;
  string url; /// artifact location (e.g. ai://default/models/fraud)
  double sizeMiB = 0;
  ArtifactStatus status = ArtifactStatus.available;
  string[] labels;

  void validate() const {
    requireId(id.value, "Model ID");
    requireId(scenarioId.value, "Scenario");
    requireText(name, "Model name");
    requireMaxLength(name, 200, "Model name");
    requireText(version_, "Model version");
    requireMaxLength(version_, 64, "Model version");
    requireMaxLength(description, 4000, "Description");
    requireArtifactUrl(url, "Model URL");
    requireRangeF(sizeMiB, 0, 1e9, "Size (MiB)");
    requireLabels(labels, "Model label");
  }
}

/// Artifact URLs: ai://, s3://, gs://, https:// or http://.
void requireArtifactUrl(string url, string what) {
  auto u = url.strip;
  if (u.length == 0)
    return;
  foreach (p; ["ai://", "s3://", "gs://", "https://", "http://", "hdl://", "wasb://"])
    if (u.startsWith(p) && u.length > p.length && !u.canFind(' ')) {
      requireMaxLength(u, 2048, what);
      return;
    }
  throw AilpException.invalid(what ~ " '" ~ url ~ "' must start with ai://, s3://, gs://, hdl://, wasb:// or http(s)://");
}

///
unittest {
  Model m;
  m.id = ModelId("m1");
  m.scenarioId = ScenarioId("s");
  m.name = "fraud-model";
  m.url = "ai://default/models/fraud";
  m.validate();
  m.url = "c:\\models";
  assert(failsWith(AilpErrorKind.invalid, () { m.validate(); }));
}
