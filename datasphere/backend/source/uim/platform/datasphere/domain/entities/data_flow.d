/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A data flow: reads source objects of the space (remote tables, views),
/// applies transformations and loads a target table. It must be deployed
/// before it runs.
module uim.platform.datasphere.domain.entities.data_flow;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// Kinds of transformation steps ("<kind>: <expression>").
enum string[] transformKinds = ["filter", "projection", "join", "union", "aggregation", "calculated", "script"];

struct DataFlow {
  mixin TenantEntity!DataFlowId;

  SpaceId spaceId;
  string name;
  string businessName;
  string description;
  string[] sourceObjects; /// names of remote tables / views of the space
  string[] transforms; /// "filter: COUNTRY = 'DE'", "projection: A, B" …
  string targetTable; /// technical name of the target table
  LoadMode loadMode = LoadMode.append;
  DeploymentStatus deploymentStatus = DeploymentStatus.notDeployed;
  long deployedAt;
  RunStatus lastRunStatus = RunStatus.notRun;
  long lastRunAt;
  long lastRunDurationMs;
  long targetRows; /// rows in the target after the last run
  long targetBytes; /// disk used by the target
  string lastRunMessage;

  bool isDeployed() const {
    return deploymentStatus != DeploymentStatus.notDeployed;
  }

  void validate() const {
    requireId(id.value, "Data flow ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the data flow is required");
    requireId(name, "Technical name");
    requireMaxLength(businessName, 200, "Business name");
    requireMaxLength(description, 2000, "Description");
    foreach (s; sourceObjects)
      requireId(s, "Source object");
    if (targetTable.length)
      requireId(targetTable, "Target table");
    foreach (t; transforms) {
      auto colon = t.indexOf(':');
      auto kind = colon > 0 ? t[0 .. colon].strip.toLower : "";
      if (!transformKinds.canFind(kind) || t[colon + 1 .. $].strip.length == 0)
        throw DspException.invalid("Transformation '" ~ t ~ "' must have the form <kind>: <expression> (kinds: "
            ~ transformKinds.join(", ") ~ ")");
    }
  }

  /// Deployment needs at least one source and a target.
  void requireDeployable() const {
    if (sourceObjects.length == 0)
      throw DspException.ruleViolation("Data flow '" ~ name ~ "' has no source");
    if (targetTable.length == 0)
      throw DspException.ruleViolation("Data flow '" ~ name ~ "' has no target table");
    if (sourceObjects.canFind(targetTable))
      throw DspException.ruleViolation("Data flow '" ~ name ~ "' must not load its own source");
  }
}

///
unittest {
  DataFlow f;
  f.id = DataFlowId("f");
  f.spaceId = SpaceId("SALES");
  f.name = "DF_ORDERS";
  f.transforms = ["filter: COUNTRY = 'DE'"];
  f.validate();
  assert(failsWith(DspErrorKind.ruleViolation, () { f.requireDeployable(); }));
  f.sourceObjects = ["S4_SALES_ORDERS"];
  f.targetTable = "T_ORDERS_DE";
  f.requireDeployable();
  f.transforms = ["sort: A"];
  assert(failsWith(DspErrorKind.invalid, () { f.validate(); }));
}
