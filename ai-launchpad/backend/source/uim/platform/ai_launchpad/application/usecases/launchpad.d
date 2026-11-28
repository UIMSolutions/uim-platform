/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The launchpad: the tile catalog (maintained in the administration) and
/// the tiles of the current user — visible tiles whose required scope the
/// user holds, ordered by group and sort order, with their KPI values.
module uim.platform.ai_launchpad.application.usecases.launchpad;

import std.traits : FieldNameTuple;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// Numeric members of AilpStatistics (all but the tenant): the KPIs a tile may show.
string[] statisticNames() {
  string[] names;
  static foreach (name; FieldNameTuple!AilpStatistics)
    static if (name != "tenantId")
      names ~= name;
  return names;
}

/// The value of a statistic by name.
long statisticValue(const AilpStatistics s, string name) @trusted {
  static foreach (member; FieldNameTuple!AilpStatistics)
    static if (member != "tenantId")
      if (member == name)
        return __traits(getMember, s, member);
  return 0;
}

class ManageTilesUseCase : ResourceInteractor!(Tile, TileId, TileInput), IManageTiles {
  protected IAilpStatisticsService statistics;

  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy,
    IAilpStatisticsService statistics) {
    super(repos, clock, audit, unitOfWork, policy);
    this.statistics = statistics;
  }

  protected override IAilpRepository!(Tile, TileId) store() {
    return repos.tiles;
  }

  protected override string what() {
    return "Tile";
  }

  protected override string eventPrefix() {
    return "tile";
  }

  protected override void check(TenantId t, const Tile e) {
    e.validate(statisticNames);
  }

  protected override TileInput toInput(const Tile e) {
    return TileInput(e.title, e.subtitle, e.info, e.icon, e.groupName, e.sortOrder, cast(string) e.targetType, e.target,
      e.kpi, e.kpiUnit, e.requiredScope, e.visible);
  }

  protected override void fromInput(TenantId t, ref Tile e, TileInput i, bool creating) {
    e.title = i.title.strip;
    e.subtitle = i.subtitle.strip;
    e.info = i.info.strip;
    e.icon = i.icon.strip;
    e.groupName = i.groupName.strip;
    e.sortOrder = i.sortOrder;
    e.targetType = parseDomainEnumOr!TileTargetType(i.targetType, TileTargetType.app, "tile target type");
    e.target = i.target.strip;
    e.kpi = i.kpi.strip;
    e.kpiUnit = i.kpiUnit.strip;
    auto s = i.requiredScope.strip;
    e.requiredScope = s.length ? canonicalScope(s).length ? canonicalScope(s) : s : "";
    e.visible = i.visible;
  }

  LaunchpadTile[] launchpad(TenantId t, const string[] scopes, bool enforceScopes) {
    auto tiles = repos.tiles.findAll(t).filter!(x => x.visible && (!enforceScopes || x.permits(scopes))).array;
    tiles.sort!((a, b) => a.groupName != b.groupName ? groupRank(tiles, a.groupName) < groupRank(tiles, b.groupName)
        : a.sortOrder != b.sortOrder ? a.sortOrder < b.sortOrder : a.title < b.title);
    LaunchpadTile[] result;
    AilpStatistics stats;
    auto computed = false;
    foreach (x; tiles) {
      LaunchpadTile lt;
      lt.tile = x;
      if (x.kpi.length) {
        if (!computed) {
          stats = statistics.compute(t);
          computed = true;
        }
        lt.hasKpi = true;
        lt.kpiValue = statisticValue(stats, x.kpi);
      }
      result ~= lt;
    }
    return result;
  }

  /// Groups appear in the order of their lowest sort order.
  protected static int groupRank(const Tile[] tiles, string group) {
    int rank = int.max;
    foreach (x; tiles)
      if (x.groupName == group && x.sortOrder < rank)
        rank = x.sortOrder;
    return rank;
  }

  size_t ensureDefaults(TenantId t) {
    if (repos.tiles.countAll(t) > 0)
      return 0;
    return writeDefaults(t, UserId(systemActor));
  }

  size_t restoreDefaults(TenantId t, UserId actor) {
    size_t n;
    batch(() {
      foreach (x; repos.tiles.findAll(t))
        repos.tiles.removeById(t, x.id);
      n = writeDefaults(t, actor);
    });
    emit("tile.defaultsRestored", t, actor, t.value, Json(["tiles": Json(n)]));
    return n;
  }

  protected size_t writeDefaults(TenantId t, UserId actor) {
    size_t n;
    batch(() {
      foreach (d; defaultTiles) {
        Tile x;
        stampCreated!(Tile, TileId)(x, t, actor, d.id, nextTime);
        fromInput(t, x, d.input, true);
        check(t, x);
        repos.tiles.save(x);
        n++;
      }
    });
    return n;
  }
}

///
unittest {
  auto names = statisticNames();
  assert(names.canFind("runningExecutions") && !names.canFind("tenantId"));
  AilpStatistics s;
  s.prompts = 7;
  assert(statisticValue(s, "prompts") == 7 && statisticValue(s, "nope") == 0);
}
