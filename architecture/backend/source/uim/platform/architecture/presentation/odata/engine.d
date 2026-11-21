/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST facade, the CLI and the GUI.
module uim.platform.architecture.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates ArchitectureException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

ODataEngine architectureEngine(ArchitecturePorts ports, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(architectureModel());

  BuildingBlock[] allBlocks(TenantId t) {
    return ports.blocks.listBlocks(t);
  }

  Relationship[] allRelationships(TenantId t) {
    return ports.relationships.listRelationships(t);
  }

  // ── Building blocks ─────────────────────────────────────────────────────
  Json blockWithFigures(TenantId t, const BuildingBlock b) {
    auto figures = blockFigures(allBlocks(t), allRelationships(t));
    return blockRow(b, figures.get(b.id.value, BlockFigures.init));
  }

  auto blocks = new DelegateEntitySetProvider;
  blocks.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto all = allBlocks(t);
    auto figures = blockFigures(all, allRelationships(t));
    return all.map!(b => blockRow(b, figures.get(b.id.value, BlockFigures.init))).array;
  };
  blocks.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    return blockWithFigures(t, ports.blocks.getBlock(t, BuildingBlockId(key)));
  };
  blocks.onCreate = (const RequestContext ctx, Json p) {
    auto b = ports.blocks.createBlock(createBlockRequest(ctx, p));
    return blockWithFigures(b.tenantId, b);
  };
  blocks.onUpdate = (const RequestContext ctx, string key, Json p) {
    auto b = ports.blocks.updateBlock(updateBlockRequest(ctx, key, p));
    return blockWithFigures(b.tenantId, b);
  };
  blocks.onRemove = (const RequestContext ctx, string key) {
    ports.blocks.deleteBlock(tenantOf(ctx), BuildingBlockId(key), actorOf(ctx));
  };

  // ── Relationships ───────────────────────────────────────────────────────
  Json relationshipWithNames(TenantId t, const Relationship r) {
    auto all = allBlocks(t);
    auto byId = indexById(all);
    BuildingBlock source, target;
    if (auto i = r.sourceId.value in byId)
      source = all[*i];
    if (auto i = r.targetId.value in byId)
      target = all[*i];
    return relationshipRow(r, source, target);
  }

  auto relationships = new DelegateEntitySetProvider;
  relationships.onList = (const RequestContext ctx) {
    auto t = tenantOf(ctx);
    auto all = allBlocks(t);
    auto byId = indexById(all);
    BuildingBlock lookup(BuildingBlockId id) {
      auto i = id.value in byId;
      return i is null ? BuildingBlock.init : all[*i];
    }

    return allRelationships(t).map!(r => relationshipRow(r, lookup(r.sourceId), lookup(r.targetId))).array;
  };
  relationships.onGet = (const RequestContext ctx, string key) {
    auto t = tenantOf(ctx);
    return relationshipWithNames(t, ports.relationships.getRelationship(t, RelationshipId(key)));
  };
  relationships.onCreate = (const RequestContext ctx, Json p) {
    auto r = ports.relationships.createRelationship(createRelationshipRequest(ctx, p));
    return relationshipWithNames(r.tenantId, r);
  };
  relationships.onUpdate = (const RequestContext ctx, string key, Json p) {
    auto r = ports.relationships.updateRelationship(updateRelationshipRequest(ctx, key, p));
    return relationshipWithNames(r.tenantId, r);
  };
  relationships.onRemove = (const RequestContext ctx, string key) {
    ports.relationships.deleteRelationship(tenantOf(ctx), RelationshipId(key), actorOf(ctx));
  };

  // ── Analysis (read only) ────────────────────────────────────────────────
  auto gaps = new DelegateEntitySetProvider;
  gaps.onList = (const RequestContext ctx) => ports.analysis.gaps(tenantOf(ctx)).map!(b => blockSummaryRow(b)).array;

  auto orphans = new DelegateEntitySetProvider;
  orphans.onList = (const RequestContext ctx) => ports.analysis.orphans(tenantOf(ctx)).map!(b => blockSummaryRow(b)).array;

  auto risks = new DelegateEntitySetProvider;
  risks.onList = (const RequestContext ctx) => ports.analysis.phaseOutRisks(tenantOf(ctx)).map!(r => phaseOutRow(r)).array;

  auto elementTypes = new DelegateEntitySetProvider;
  elementTypes.keyProperty = "name";
  elementTypes.onList = (const RequestContext ctx) => archimateElementTypes.map!(e => elementTypeRow(e)).array;

  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.analysis.statistics(tenantOf(ctx)),
    ctx.tenantId);

  engine.provide("BuildingBlocks", new PortProvider(blocks))
    .provide("Relationships", new PortProvider(relationships))
    .provide("Gaps", new PortProvider(gaps))
    .provide("Orphans", new PortProvider(orphans))
    .provide("PhaseOutRisks", new PortProvider(risks))
    .provide("ElementTypes", new PortProvider(elementTypes))
    .provide("Statistics", new PortProvider(statistics));

  // ── Actions ─────────────────────────────────────────────────────────────
  engine.handle("ChangeStatus", (const RequestContext ctx, Json p) => translated!Json(() {
      auto t = tenantOf(ctx);
      auto id = BuildingBlockId(textOf(p, "id"));
      auto before = ports.blocks.getBlock(t, id).status;
      auto b = ports.blocks.changeStatus(t, id, textOf(p, "status"), actorOf(ctx));
      return Json([
        "id": Json(b.id.value), "previousStatus": Json(cast(string) before), "status": Json(cast(string) b.status)
      ]);
    }));
  engine.handle("AnalyzeImpact", (const RequestContext ctx, Json p) => translated!Json(() {
      auto impact = ports.analysis.impact(tenantOf(ctx), BuildingBlockId(textOf(p, "id")));
      auto rows = Json.emptyArray;
      foreach (i; impact.impacted)
        rows ~= impactRow(i);
      return rows;
    }));
  engine.handle("ExportArchiMate", (const RequestContext ctx, Json p) => translated!Json(() {
      auto t = tenantOf(ctx);
      auto xml = ports.exporter.exportArchiMate(t, textOf(p, "modelName"));
      return Json([
        "fileName": Json("architecture-" ~ t.value ~ ".xml"), "contentType": Json("application/xml"),
        "elements": Json(ports.blocks.listBlocks(t).length), "content": Json(xml)
      ]);
    }));
  engine.handle("SeedDemoData", (const RequestContext ctx, Json p) => translated!Json(() => seedRow(
      ports.seeder.seed(tenantOf(ctx), actorOf(ctx)))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}
