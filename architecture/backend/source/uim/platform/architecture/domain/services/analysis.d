/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Architecture analysis over the repository content (pure functions):
///   gaps        ABBs without a (non retired) SBB realizing them — TOGAF gap analysis
///   orphans     blocks without any relationship
///   phase-out   deprecated/retired blocks that in-use blocks still depend on
///   impact      transitive dependents of a block (what is affected by a change)
///   statistics  the KPIs of the repository
module uim.platform.architecture.domain.services.analysis;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

/// "dependent depends on provider": a change of provider affects dependent.
struct DependencyEdge {
  BuildingBlockId provider;
  BuildingBlockId dependent;
  ArchiMateRelationshipType type;
}

/// All dependency edges: explicit relationships plus the implicit
/// realization of SBB.realizesId.
DependencyEdge[] dependencyEdges(BuildingBlock[] blocks, Relationship[] relationships) {
  DependencyEdge[] edges;
  foreach (r; relationships) {
    if (!carriesDependency(r.type))
      continue;
    edges ~= sourceImpactsTarget(r.type) ? DependencyEdge(r.sourceId, r.targetId, r.type) : DependencyEdge(r.targetId,
      r.sourceId, r.type);
  }
  foreach (b; blocks)
    if (!b.realizesId.isNull)
      edges ~= DependencyEdge(b.id, b.realizesId, ArchiMateRelationshipType.realization);
  return edges;
}

/// Position of each block by id.
size_t[string] indexById(BuildingBlock[] blocks) {
  size_t[string] index;
  foreach (i, b; blocks)
    index[b.id.value] = i;
  return index;
}

/// The solution blocks realizing an architecture block (field or relationship).
BuildingBlockId[] realizersOf(BuildingBlockId abb, BuildingBlock[] blocks, Relationship[] relationships) {
  BuildingBlockId[] ids;
  foreach (b; blocks)
    if (b.kind == BlockKind.solution && b.realizesId == abb && b.status != LifecycleStatus.retired)
      ids ~= b.id;
  foreach (r; relationships)
    if (r.type == ArchiMateRelationshipType.realization && r.targetId == abb && !ids.canFind(r.sourceId)) {
      auto source = blocks.find!(b => b.id == r.sourceId);
      if (!source.empty && source.front.kind == BlockKind.solution && source.front.status != LifecycleStatus.retired)
        ids ~= r.sourceId;
    }
  return ids;
}

/// Architecture building blocks (not retired) that no solution building block realizes.
BuildingBlock[] findGaps(BuildingBlock[] blocks, Relationship[] relationships) {
  BuildingBlock[] gaps;
  foreach (b; blocks)
    if (b.kind == BlockKind.architecture && b.status != LifecycleStatus.retired
      && realizersOf(b.id, blocks, relationships).length == 0)
      gaps ~= b;
  return gaps;
}

/// Blocks (not retired) without any relationship or realization link.
BuildingBlock[] findOrphans(BuildingBlock[] blocks, Relationship[] relationships) {
  bool[string] linked;
  foreach (r; relationships) {
    linked[r.sourceId.value] = true;
    linked[r.targetId.value] = true;
  }
  foreach (b; blocks)
    if (!b.realizesId.isNull) {
      linked[b.id.value] = true;
      linked[b.realizesId.value] = true;
    }
  BuildingBlock[] orphans;
  foreach (b; blocks)
    if (b.status != LifecycleStatus.retired && b.id.value !in linked)
      orphans ~= b;
  return orphans;
}

/// A deprecated or retired block that in-use blocks still depend on.
struct PhaseOutRisk {
  BuildingBlock block;
  BuildingBlockId[] dependents; /// in-use blocks depending on it
}

PhaseOutRisk[] findPhaseOutRisks(BuildingBlock[] blocks, Relationship[] relationships) {
  auto byId = indexById(blocks);
  auto edges = dependencyEdges(blocks, relationships);
  PhaseOutRisk[] risks;
  foreach (b; blocks) {
    if (!isPhasingOut(b.status))
      continue;
    BuildingBlockId[] dependents;
    foreach (e; edges)
      if (e.provider == b.id && e.dependent.value in byId && isInUse(blocks[byId[e.dependent.value]].status)
        && !dependents.canFind(e.dependent))
        dependents ~= e.dependent;
    if (dependents.length > 0)
      risks ~= PhaseOutRisk(b, dependents);
  }
  return risks;
}

/// One block affected by a change.
struct ImpactedBlock {
  BuildingBlockId id;
  string name;
  BlockKind kind;
  LifecycleStatus status;
  size_t depth; /// 1 = direct dependent
  ArchiMateRelationshipType via; /// relationship through which it is reached
  BuildingBlockId viaBlock; /// the block it depends on
}

struct ImpactAnalysis {
  BuildingBlockId root;
  ImpactedBlock[] impacted; /// breadth first (by depth)

  size_t direct() const {
    return impacted.count!(i => i.depth == 1);
  }

  size_t total() const {
    return impacted.length;
  }

  size_t maxDepth() const {
    return impacted.length ? impacted[$ - 1].depth : 0;
  }
}

/// Transitive dependents of root (breadth first, cycles are cut).
ImpactAnalysis analyzeImpact(BuildingBlockId root, BuildingBlock[] blocks, Relationship[] relationships) {
  auto byId = indexById(blocks);
  auto edges = dependencyEdges(blocks, relationships);

  ImpactAnalysis result;
  result.root = root;
  bool[string] seen = [root.value: true];
  BuildingBlockId[] frontier = [root];
  size_t depth;
  while (frontier.length > 0) {
    depth++;
    BuildingBlockId[] next;
    foreach (provider; frontier)
      foreach (e; edges)
        if (e.provider == provider && e.dependent.value !in seen && e.dependent.value in byId) {
          seen[e.dependent.value] = true;
          auto b = blocks[byId[e.dependent.value]];
          result.impacted ~= ImpactedBlock(b.id, b.name, b.kind, b.status, depth, e.type, provider);
          next ~= e.dependent;
        }
    frontier = next;
  }
  return result;
}

/// Key figures of the repository of one tenant.
struct ArchitectureStatistics {
  size_t blocks;
  size_t[BlockKind] byKind;
  size_t[LifecycleStatus] byStatus;
  size_t relationships;
  size_t architectureBlocks; /// ABBs not retired
  size_t realizedArchitectureBlocks;
  size_t gaps;
  size_t orphans;
  size_t phaseOutRisks;
  size_t expired; /// in use although validUntil has passed
  long computedAt;

  /// Share of ABBs realized by at least one SBB (100 if there are none).
  long coveragePercent() const {
    return architectureBlocks == 0 ? 100 : cast(long)(realizedArchitectureBlocks * 100 / architectureBlocks);
  }

  size_t ofKind(BlockKind k) const {
    return byKind.get(k, 0);
  }

  size_t ofStatus(LifecycleStatus s) const {
    return byStatus.get(s, 0);
  }
}

ArchitectureStatistics computeStatistics(BuildingBlock[] blocks, Relationship[] relationships, long now) {
  ArchitectureStatistics s;
  s.computedAt = now;
  s.blocks = blocks.length;
  s.relationships = relationships.length;
  foreach (b; blocks) {
    s.byKind[b.kind]++;
    s.byStatus[b.status]++;
    if (b.validUntil > 0 && b.validUntil < now && isInUse(b.status))
      s.expired++;
    if (b.kind == BlockKind.architecture && b.status != LifecycleStatus.retired) {
      s.architectureBlocks++;
      if (realizersOf(b.id, blocks, relationships).length > 0)
        s.realizedArchitectureBlocks++;
    }
  }
  s.gaps = s.architectureBlocks - s.realizedArchitectureBlocks;
  s.orphans = findOrphans(blocks, relationships).length;
  s.phaseOutRisks = findPhaseOutRisks(blocks, relationships).length;
  return s;
}

version (unittest) {
  private BuildingBlock blk(string id, BlockKind kind, LifecycleStatus status = LifecycleStatus.active, string realizes = "") {
    BuildingBlock b;
    b.id = BuildingBlockId(id);
    b.kind = kind;
    b.name = id;
    b.status = status;
    b.realizesId = BuildingBlockId(realizes);
    return b;
  }

  private Relationship rel(string id, ArchiMateRelationshipType type, string source, string target) {
    Relationship r;
    r.id = RelationshipId(id);
    r.type = type;
    r.sourceId = BuildingBlockId(source);
    r.targetId = BuildingBlockId(target);
    return r;
  }
}

///
unittest {
  alias K = BlockKind;
  alias R = ArchiMateRelationshipType;
  auto blocks = [
    blk("abb-crm", K.architecture), blk("abb-bi", K.architecture), blk("sbb-crm", K.solution, LifecycleStatus.active, "abb-crm"),
    blk("tbb-db", K.technology, LifecycleStatus.deprecated_), blk("dbb-customer", K.data), blk("bbb-sales", K.business),
    blk("tbb-k8s", K.technology)
  ];
  auto rels = [
    rel("r1", R.serving, "tbb-db", "sbb-crm"), rel("r2", R.access, "sbb-crm", "dbb-customer"),
    rel("r3", R.serving, "sbb-crm", "bbb-sales")
  ];

  assert(findGaps(blocks, rels).map!(b => b.id.value).array == ["abb-bi"]);
  assert(findOrphans(blocks, rels).map!(b => b.id.value).array == ["abb-bi", "tbb-k8s"]);
  auto risks = findPhaseOutRisks(blocks, rels);
  assert(risks.length == 1 && risks[0].block.id.value == "tbb-db" && risks[0].dependents[0].value == "sbb-crm");

  // tbb-db → sbb-crm → (abb-crm via realization, bbb-sales via serving); access is reversed: no impact on the data object
  auto impact = analyzeImpact(BuildingBlockId("tbb-db"), blocks, rels);
  assert(impact.direct == 1 && impact.total == 3 && impact.maxDepth == 2, impact.impacted.map!(i => i.id.value).join(","));
  // a change of the data object affects the accessing SBB and everything depending on it
  assert(analyzeImpact(BuildingBlockId("dbb-customer"), blocks, rels).impacted[0].id.value == "sbb-crm");

  auto s = computeStatistics(blocks, rels, nowStdTime());
  assert(s.blocks == 7 && s.ofKind(K.architecture) == 2 && s.ofStatus(LifecycleStatus.deprecated_) == 1);
  assert(s.gaps == 1 && s.coveragePercent == 50 && s.orphans == 2 && s.phaseOutRisks == 1);
}
