/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entities → flat rows matching the EDM model (shared by OData, REST, CLI, GUI).
module uim.platform.architecture.presentation.odata.serializers;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

/// ISO timestamp or null.
Json timeValue(long stdTime) {
  return stdTime > 0 ? Json(isoTimeText(stdTime)) : Json(null);
}

/// ISO date (YYYY-MM-DD) or null.
Json dateValue(long stdTime) {
  return stdTime > 0 ? Json(isoTimeText(stdTime)[0 .. 10]) : Json(null);
}

Json textList(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

private void auditInto(E)(ref Json row, const E e) {
  row["tenantId"] = e.tenantId.value;
  row["createdAt"] = timeValue(e.createdAt);
  row["createdBy"] = e.createdBy.value;
  row["updatedAt"] = timeValue(e.updatedAt);
  row["updatedBy"] = e.updatedBy.value;
}

/// Derived figures of a block (computed by the engine from all relationships).
struct BlockFigures {
  size_t relationships;
  size_t realizedBy;
  string realizesName;
}

Json blockSummaryRow(const BuildingBlock b) {
  auto row = Json.emptyObject;
  row["id"] = b.id.value;
  row["name"] = b.name;
  row["kind"] = cast(string) b.kind;
  row["kindAbbreviation"] = abbreviation(b.kind);
  row["status"] = cast(string) b.status;
  row["owner"] = b.owner;
  row["elementType"] = b.effectiveElementType;
  row["capability"] = b.capability;
  return row;
}

Json blockRow(const BuildingBlock b, BlockFigures f = BlockFigures.init) {
  auto row = blockSummaryRow(b);
  auditInto(row, b);
  row["description"] = b.description;
  row["versionLabel"] = b.versionLabel;
  row["tags"] = textList(b.tags);
  row["domain"] = cast(string) b.domain;
  row["aspect"] = cast(string) b.aspect;
  row["viewpoint"] = b.viewpoint;
  row["interfaces"] = textList(b.interfaces);
  row["realizesId"] = b.realizesId.value;
  row["realizesName"] = f.realizesName;
  row["vendor"] = b.vendor;
  row["endpoint"] = b.endpoint;
  row["dataClassification"] = b.dataClassification;
  row["dataOwner"] = b.dataOwner;
  row["sourceSystem"] = b.sourceSystem;
  row["factSheetType"] = b.factSheetType;
  row["factSheetId"] = b.factSheetId;
  row["validUntil"] = dateValue(b.validUntil);
  row["relationshipCount"] = f.relationships;
  row["realizedByCount"] = f.realizedBy;
  return row;
}

/// Figures of every block in one pass over the repository.
BlockFigures[string] blockFigures(BuildingBlock[] blocks, Relationship[] relationships) {
  BlockFigures[string] figures;
  string[string] names;
  foreach (b; blocks) {
    figures[b.id.value] = BlockFigures.init;
    names[b.id.value] = b.name;
  }
  foreach (r; relationships) {
    if (auto f = r.sourceId.value in figures)
      f.relationships++;
    if (auto f = r.targetId.value in figures)
      f.relationships++;
  }
  foreach (b; blocks)
    if (!b.realizesId.isNull)
      figures[b.id.value].realizesName = names.get(b.realizesId.value, "");
  foreach (b; blocks)
    if (b.kind == BlockKind.architecture)
      figures[b.id.value].realizedBy = realizersOf(b.id, blocks, relationships).length;
  return figures;
}

Json relationshipRow(const Relationship r, const BuildingBlock source, const BuildingBlock target) {
  auto row = Json.emptyObject;
  row["id"] = r.id.value;
  auditInto(row, r);
  row["type"] = cast(string) r.type;
  row["sourceId"] = r.sourceId.value;
  row["sourceName"] = source.name;
  row["sourceKind"] = source.isNull ? "" : cast(string) source.kind;
  row["targetId"] = r.targetId.value;
  row["targetName"] = target.name;
  row["targetKind"] = target.isNull ? "" : cast(string) target.kind;
  row["description"] = r.description;
  return row;
}

Json phaseOutRow(const PhaseOutRisk risk) {
  auto row = blockSummaryRow(risk.block);
  row["validUntil"] = dateValue(risk.block.validUntil);
  row["dependentCount"] = risk.dependents.length;
  auto ids = Json.emptyArray;
  foreach (d; risk.dependents)
    ids ~= Json(d.value);
  row["dependents"] = ids;
  return row;
}

Json impactRow(const ImpactedBlock i) {
  auto row = Json.emptyObject;
  row["id"] = i.id.value;
  row["name"] = i.name;
  row["kind"] = cast(string) i.kind;
  row["kindAbbreviation"] = abbreviation(i.kind);
  row["status"] = cast(string) i.status;
  row["depth"] = i.depth;
  row["via"] = cast(string) i.via;
  row["viaBlockId"] = i.viaBlock.value;
  return row;
}

Json elementTypeRow(const ElementTypeInfo e) {
  auto row = Json.emptyObject;
  row["name"] = e.name;
  row["domain"] = cast(string) e.domain;
  row["aspect"] = cast(string) e.aspect;
  return row;
}

Json statisticsRow(const ArchitectureStatistics s, string tenant) {
  auto row = Json.emptyObject;
  row["tenantId"] = tenant;
  row["blocks"] = s.blocks;
  row["architectureBlocks"] = s.ofKind(BlockKind.architecture);
  row["solutionBlocks"] = s.ofKind(BlockKind.solution);
  row["dataBlocks"] = s.ofKind(BlockKind.data);
  row["businessBlocks"] = s.ofKind(BlockKind.business);
  row["technologyBlocks"] = s.ofKind(BlockKind.technology);
  row["proposed"] = s.ofStatus(LifecycleStatus.proposed);
  row["approved"] = s.ofStatus(LifecycleStatus.approved);
  row["inDevelopment"] = s.ofStatus(LifecycleStatus.inDevelopment);
  row["active"] = s.ofStatus(LifecycleStatus.active);
  row["deprecated"] = s.ofStatus(LifecycleStatus.deprecated_);
  row["retired"] = s.ofStatus(LifecycleStatus.retired);
  row["relationships"] = s.relationships;
  row["gaps"] = s.gaps;
  row["coveragePercent"] = s.coveragePercent;
  row["orphans"] = s.orphans;
  row["phaseOutRisks"] = s.phaseOutRisks;
  row["expired"] = s.expired;
  row["computedAt"] = timeValue(s.computedAt);
  return row;
}

Json seedRow(const SeedResult r) {
  auto row = Json.emptyObject;
  row["blocks"] = r.blocks;
  row["relationships"] = r.relationships;
  return row;
}
