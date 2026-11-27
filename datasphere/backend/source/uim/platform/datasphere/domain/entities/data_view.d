/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A view: a SQL SELECT over objects of the space with a semantic usage.
/// Exposed views can be consumed by SAP Analytics Cloud and other tools;
/// persisted views keep a materialised copy (view persistence).
module uim.platform.datasphere.domain.entities.data_view;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct DataView {
  mixin TenantEntity!DataViewId;

  SpaceId spaceId;
  string name; /// technical name in the space
  string businessName;
  string description;
  ViewSemantic semantic = ViewSemantic.relationalDataset;
  string sqlExpression;
  string[] sourceObjects; /// derived from the SQL (FROM / JOIN)
  string[] columns; /// "NAME:TYPE(len) [key]"
  bool exposed; /// exposed for consumption
  DeploymentStatus deploymentStatus = DeploymentStatus.notDeployed;
  long deployedAt;
  bool persisted; /// a materialised copy exists
  long rowCount; /// rows of the persisted copy
  long persistedBytes;
  long persistedAt;
  RunStatus lastRunStatus = RunStatus.notRun;
  string lastRunMessage;

  bool isDeployed() const {
    return deploymentStatus != DeploymentStatus.notDeployed;
  }

  void validate() const {
    requireId(id.value, "View ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the view is required");
    requireId(name, "Technical name");
    requireMaxLength(businessName, 200, "Business name");
    requireMaxLength(description, 2000, "Description");
    if (sqlExpression.strip.length)
      analyzeViewSql(sqlExpression);
    auto cols = parseColumns(columns);
    auto analytic = semantic == ViewSemantic.fact || semantic == ViewSemantic.analyticalDataset;
    if (analytic && exposed && cols.length && !cols.any!(c => numericColumnTypes.canFind(c.type)))
      throw DspException.invalid("An exposed " ~ cast(string) semantic ~ " needs at least one numeric measure column");
  }

  /// Deployment needs SQL.
  void requireDeployable() const {
    if (sqlExpression.strip.length == 0)
      throw DspException.ruleViolation("View '" ~ name ~ "' has no SQL expression");
  }
}

///
unittest {
  DataView v;
  v.id = DataViewId("v");
  v.spaceId = SpaceId("SALES");
  v.name = "V_ORDERS";
  v.validate();
  assert(failsWith(DspErrorKind.ruleViolation, () { v.requireDeployable(); }));
  v.sqlExpression = "SELECT * FROM S4_SALES_ORDERS";
  v.requireDeployable();
  v.semantic = ViewSemantic.analyticalDataset;
  v.exposed = true;
  v.columns = ["SALESORDER:NVARCHAR(10) key"];
  assert(failsWith(DspErrorKind.invalid, () { v.validate(); }));
  v.columns ~= "NETAMOUNT:DECIMAL(15,2)";
  v.validate();
  v.sqlExpression = "DROP TABLE X";
  assert(failsWith(DspErrorKind.invalid, () { v.validate(); }));
}
