/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST
/// facade's payload validation, the CLI and the GtkD GUI.
///
/// Scopes: Read (reads, analysis, export), Manage (create/change/delete),
/// Govern (lifecycle decisions through the ChangeStatus action).
module uim.platform.architecture.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.architecture";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

/// The summary columns shared by the analysis sets.
private ODataEntitySetDef summary(ODataEntitySetDef set) {
  return set.property("id", Edm.string_, "Building Block", false)
    .property("name", Edm.string_, "Name")
    .property("kind", Edm.string_, "Kind")
    .property("kindAbbreviation", Edm.string_, "Type")
    .property("status", Edm.string_, "Status")
    .property("owner", Edm.string_, "Owner")
    .property("elementType", Edm.string_, "ArchiMate Element")
    .property("capability", Edm.string_, "Capability");
}

ODataServiceModel architectureModel() {
  auto m = new ODataServiceModel(odataNamespace, "ArchitectureService", "Architecture Repository");

  audited(m.entitySet("BuildingBlocks", "BuildingBlock")
      .property("id", Edm.string_, "Building Block ID")
      .property("kind", Edm.string_, "Kind", false)
      .property("kindAbbreviation", Edm.string_, "Type")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("owner", Edm.string_, "Owner")
      .property("status", Edm.string_, "Status")
      .property("versionLabel", Edm.string_, "Version")
      .collection("tags", Edm.string_, "Tags")
      .property("elementType", Edm.string_, "ArchiMate Element")
      .property("domain", Edm.string_, "ArchiMate Layer")
      .property("aspect", Edm.string_, "ArchiMate Aspect")
      .property("viewpoint", Edm.string_, "Viewpoint")
      .property("capability", Edm.string_, "Capability")
      .collection("interfaces", Edm.string_, "Interfaces")
      .property("realizesId", Edm.string_, "Realizes (ABB)")
      .property("realizesName", Edm.string_, "Realizes")
      .property("vendor", Edm.string_, "Vendor / Component")
      .property("endpoint", Edm.string_, "Endpoint")
      .property("dataClassification", Edm.string_, "Data Classification")
      .property("dataOwner", Edm.string_, "Data Owner")
      .property("sourceSystem", Edm.string_, "System of Record")
      .property("factSheetType", Edm.string_, "LeanIX Fact Sheet Type")
      .property("factSheetId", Edm.string_, "LeanIX Fact Sheet ID")
      .property("validUntil", Edm.date, "Valid Until")
      .property("relationshipCount", Edm.int32, "Relationships")
      .property("realizedByCount", Edm.int32, "Realized By")
      .computed("kindAbbreviation", "domain", "aspect", "realizesName", "relationshipCount", "realizedByCount")
      .immutableProps("kind", "status"))
    .writable()
    .titled("Building Block", "Building Blocks", "name", "description")
    .columns("name", "kindAbbreviation", "status", "elementType", "owner", "versionLabel", "relationshipCount")
    .filters("kind", "status", "owner", "domain")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Relationships", "Relationship")
      .property("id", Edm.string_, "Relationship ID")
      .property("type", Edm.string_, "Type", false)
      .property("sourceId", Edm.string_, "Source", false)
      .property("sourceName", Edm.string_, "Source Name")
      .property("sourceKind", Edm.string_, "Source Kind")
      .property("targetId", Edm.string_, "Target", false)
      .property("targetName", Edm.string_, "Target Name")
      .property("targetKind", Edm.string_, "Target Kind")
      .property("description", Edm.string_, "Description")
      .computed("sourceName", "sourceKind", "targetName", "targetKind")
      .immutableProps("type", "sourceId", "targetId"))
    .writable()
    .titled("Relationship", "Relationships", "type", "description")
    .columns("sourceName", "type", "targetName", "description")
    .filters("type", "sourceId", "targetId")
    .scopes(readScope, manageScope);

  summary(m.entitySet("Gaps", "Gap"))
    .titled("Gap", "Gaps (ABBs without SBB)", "name", "capability")
    .columns("name", "id", "status", "capability", "owner")
    .filters("status", "owner")
    .scopes(readScope, "");

  summary(m.entitySet("Orphans", "Orphan"))
    .titled("Orphan", "Orphans (no relationships)", "name", "kind")
    .columns("name", "kindAbbreviation", "status", "owner")
    .filters("kind", "status")
    .scopes(readScope, "");

  summary(m.entitySet("PhaseOutRisks", "PhaseOutRisk"))
    .property("validUntil", Edm.date, "Valid Until")
    .property("dependentCount", Edm.int32, "Dependents in Use")
    .collection("dependents", Edm.string_, "Dependents")
    .titled("Phase-out Risk", "Phase-out Risks", "name", "status")
    .columns("name", "kindAbbreviation", "status", "validUntil", "dependentCount")
    .filters("kind", "status")
    .scopes(readScope, "");

  m.entitySet("ElementTypes", "ElementType")
    .keyed("name")
    .property("name", Edm.string_, "ArchiMate Element", false)
    .property("domain", Edm.string_, "Layer")
    .property("aspect", Edm.string_, "Aspect")
    .titled("ArchiMate Element Type", "ArchiMate Element Types", "name", "domain")
    .columns("name", "domain", "aspect")
    .filters("domain", "aspect")
    .scopes(readScope, "");

  m.singletonSet("Statistics", "Statistic")
    .keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false)
    .property("blocks", Edm.int32, "Building Blocks")
    .property("architectureBlocks", Edm.int32, "Architecture Building Blocks")
    .property("solutionBlocks", Edm.int32, "Solution Building Blocks")
    .property("dataBlocks", Edm.int32, "Data Building Blocks")
    .property("businessBlocks", Edm.int32, "Business Building Blocks")
    .property("technologyBlocks", Edm.int32, "Technology Building Blocks")
    .property("proposed", Edm.int32, "Proposed")
    .property("approved", Edm.int32, "Approved")
    .property("inDevelopment", Edm.int32, "In Development")
    .property("active", Edm.int32, "Active")
    .property("deprecated", Edm.int32, "Deprecated")
    .property("retired", Edm.int32, "Retired")
    .property("relationships", Edm.int32, "Relationships")
    .property("gaps", Edm.int32, "Gaps")
    .property("coveragePercent", Edm.int32, "ABB Coverage (%)")
    .property("orphans", Edm.int32, "Orphans")
    .property("phaseOutRisks", Edm.int32, "Phase-out Risks")
    .property("expired", Edm.int32, "Past Valid Until")
    .property("computedAt", Edm.dateTimeOffset, "Computed At")
    .titled("Statistics", "Statistics")
    .scopes(readScope, "");

  m.complexType("StatusResult")
    .property("id", Edm.string_, "Building Block")
    .property("previousStatus", Edm.string_, "Previous Status")
    .property("status", Edm.string_, "Status");

  m.complexType("ImpactedBlock")
    .property("id", Edm.string_, "Building Block")
    .property("name", Edm.string_, "Name")
    .property("kind", Edm.string_, "Kind")
    .property("kindAbbreviation", Edm.string_, "Type")
    .property("status", Edm.string_, "Status")
    .property("depth", Edm.int32, "Depth")
    .property("via", Edm.string_, "Via Relationship")
    .property("viaBlockId", Edm.string_, "Depends On");

  m.complexType("ExportResult")
    .property("fileName", Edm.string_, "File Name")
    .property("contentType", Edm.string_, "Content Type")
    .property("elements", Edm.int32, "Elements")
    .property("content", Edm.string_, "Content");

  m.complexType("SeedResult")
    .property("blocks", Edm.int32, "Building Blocks")
    .property("relationships", Edm.int32, "Relationships");

  m.action("ChangeStatus", "StatusResult")
    .parameter("id", Edm.string_, false)
    .parameter("status", Edm.string_, false)
    .labelled("Change Lifecycle Status (approve, activate, deprecate, retire)")
    .requires(governScope);
  auto impact = m.action("AnalyzeImpact", "ImpactedBlock")
    .parameter("id", Edm.string_, false)
    .labelled("Impact Analysis (what depends on a building block)")
    .requires(readScope);
  impact.returnsCollection = true;
  m.action("ExportArchiMate", "ExportResult")
    .parameter("modelName", Edm.string_)
    .labelled("Export as ArchiMate Model Exchange File")
    .requires(readScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Landscape").requires(manageScope);

  m.validate();
  return m;
}

///
unittest {
  auto m = architectureModel();
  assert(m.has("BuildingBlocks") && m.find("Statistics").singleton);
  assert(m.find("BuildingBlocks").key == "id" && m.find("ElementTypes").key == "name");
  assert(!m.find("Gaps").insertable && m.find("Relationships").updatable);
  assert(m.find("BuildingBlocks").propertyOf("relationshipCount").computed);
  assert(m.find("BuildingBlocks").propertyOf("status").immutable_);
  assert(m.findAction("AnalyzeImpact").returnEdmType == "Collection(uim.architecture.ImpactedBlock)");
}
