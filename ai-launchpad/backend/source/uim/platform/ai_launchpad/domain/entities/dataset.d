/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A registered dataset (training or evaluation data) of a scenario.
module uim.platform.ai_launchpad.domain.entities.dataset;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Dataset {
  mixin TenantEntity!DatasetId;

  ScenarioId scenarioId;
  string name;
  string description;
  string url;
  double sizeMiB = 0;
  ArtifactStatus status = ArtifactStatus.available;
  string[] labels;

  void validate() const {
    requireId(id.value, "Dataset ID");
    requireId(scenarioId.value, "Scenario");
    requireText(name, "Dataset name");
    requireMaxLength(name, 200, "Dataset name");
    requireMaxLength(description, 4000, "Description");
    requireText(url, "Dataset URL");
    requireArtifactUrl(url, "Dataset URL");
    requireRangeF(sizeMiB, 0, 1e9, "Size (MiB)");
    requireLabels(labels, "Dataset label");
  }
}

///
unittest {
  Dataset d;
  d.id = DatasetId("ds");
  d.scenarioId = ScenarioId("s");
  d.name = "transactions-2026";
  assert(failsWith(AilpErrorKind.invalid, () { d.validate(); }), "URL required");
  d.url = "s3://bucket/transactions.parquet";
  d.validate();
}
