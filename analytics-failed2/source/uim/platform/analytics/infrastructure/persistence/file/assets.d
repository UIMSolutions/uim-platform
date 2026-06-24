module uim.platform.analytics.infrastructure.persistence.file.assets;

// import std.file : exists, mkdirRecurse, readText, write;
// import std.json : JSONType, Json, parseJSON;
// import std.path : buildPath;
// 
// import uim.platform.analytics.domain;
import uim.platform.analytics;

// mixin(ShowModule!());

@safe:  
class FileAssetRepository : AssetRepository {
  private InsightAsset[][TenantId] byTenant;
  private string filePath;

  this(string dataPath) {
    if (!exists(dataPath)) mkdirRecurse(dataPath);
    filePath = buildPath(dataPath, "insight_assets.json");

    if (!exists(filePath)) {
      write(filePath, "[]");
    }

    loadFromDisk();
  }

  AssetId save(InsightAsset asset) {
    byTenant[asset.tenantId] ~= asset;
    flushToDisk();
    return asset.id;
  }

  bool update(InsightAsset asset) {
    auto ptr = asset.tenantId in byTenant;
    if (ptr is null) return false;

    foreach (i, existing; *ptr) {
      if (existing.id == asset.id) {
        (*ptr)[i] = asset;
        flushToDisk();
        return true;
      }
    }
    return false;
  }

  bool remove(TenantId tenantId, AssetId id) {
    auto ptr = tenantId in byTenant;
    if (ptr is null) return false;

    foreach (i, existing; *ptr) {
      if (existing.id == id) {
        (*ptr) = (*ptr)[0 .. i] ~ (*ptr)[i + 1 .. $];
        flushToDisk();
        return true;
      }
    }
    return false;
  }

  InsightAsset findById(TenantId tenantId, AssetId id) {
    auto ptr = tenantId in byTenant;
    if (ptr is null) return InsightAsset.init;
    foreach (asset; *ptr)
      if (asset.id == id) return asset;
    return InsightAsset.init;
  }

  InsightAsset[] findByTenant(TenantId tenantId) {
    auto ptr = tenantId in byTenant;
    if (ptr is null) return [];
    return (*ptr).dup;
  }

  private void loadFromDisk() {
    byTenant = null;
    auto root = parseJSON(cast(string) readText(filePath));
    if (root.type != JSONType.array) return;

    foreach (entry; root.array) {
      if (entry.type != JSONType.object) continue;

      InsightAsset a;
      if ("id" in entry.object) a.id = entry["id"].str;
      if ("tenantId" in entry.object) a.tenantId = entry["tenantId"].str;
      if ("name" in entry.object) a.name = entry["name"].str;
      if ("kind" in entry.object) a.kind = entry["kind"].str;
      if ("sourceSystem" in entry.object) a.sourceSystem = entry["sourceSystem"].str;
      if ("published" in entry.object) a.published = entry["published"].boolean;
      if ("createdAt" in entry.object) a.createdAt = cast(long) entry["createdAt"].integer;
      if ("updatedAt" in entry.object) a.updatedAt = cast(long) entry["updatedAt"].integer;

      if ("dimensions" in entry.object && entry["dimensions"].type == JSONType.array) {
        foreach (d; entry["dimensions"].array)
          if (d.type == JSONType.string) a.dimensions ~= d.str;
      }

      if ("measures" in entry.object && entry["measures"].type == JSONType.array) {
        foreach (m; entry["measures"].array)
          if (m.type == JSONType.string) a.measures ~= m.str;
      }

      byTenant[a.tenantId] ~= a;
    }
  }

  private void flushToDisk() {
    Json serialized = Json.emptyArray;

    foreach (_tenantId, assets; byTenant) {
      foreach (a; assets) {
        Json dims = a.dimensions.map!(dim => dim.toJson()).array.toJson;
        Json meas = a.measures.map!(m => m.toJson).array.toJson;

        serialized ~= Json.emptyObject
        .set("id", a.id)
        .set("tenantId", a.tenantId)
        .set("name", a.name)
        .set("kind", a.kind)
        .set("sourceSystem", a.sourceSystem)
        .set("dimensions", dims)
        .set("measures", meas)
        .set("published", a.published)
        .set("createdAt", a.createdAt)
        .set("updatedAt", a.updatedAt);
      }
    }

    write(filePath, Json(serialized).toString());
  }
}

unittest {
  import std.file : exists, isDir, mkdirRecurse, rmdirRecurse;
  import std.conv : to;
  import std.process : environment;

  auto tmpRoot = environment.get("TMPDIR", "/tmp");
  auto testDir = buildPath(tmpRoot, "analytics-file-repo-" ~ MonoTime.currTime.ticks.to!string);
  if (!exists(testDir)) mkdirRecurse(testDir);
  scope (exit) {
    if (exists(testDir) && isDir(testDir)) {
      rmdirRecurse(testDir);
    }
  }

  auto repo = new FileAssetRepository(testDir);

  InsightAsset a;
  a.id = "f1";
  a.tenantId = "tenant-f";
  a.name = "File Asset";
  a.kind = "story";
  a.sourceSystem = "file";
  a.dimensions = ["region"];
  a.measures = ["revenue"];
  a.published = false;
  a.createdAt = 10;
  a.updatedAt = 10;

  assert(repo.save(a) == "f1");
  assert(repo.findByTenant("tenant-f").length == 1);

  auto reloaded = new FileAssetRepository(testDir);
  auto loaded = reloaded.findById("tenant-f", "f1");
  assert(!loaded.isNull);
  assert(loaded.name == "File Asset");

  assert(reloaded.remove("tenant-f", "f1"));
  assert(reloaded.findByTenant("tenant-f").length == 0);
}
