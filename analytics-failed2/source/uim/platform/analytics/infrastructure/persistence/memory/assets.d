module uim.platform.analytics.infrastructure.persistence.memory.assets;

// import uim.platform.analytics.domain;
import uim.platform.analytics;
mixin(ShowModule!());

@safe:  
class MemoryAssetRepository : AssetRepository {
  private InsightAsset[][TenantId] byTenant;

  AssetId save(InsightAsset asset) {
    byTenant[asset.tenantId] ~= asset;
    return asset.id;
  }

  bool update(InsightAsset asset) {
    auto ptr = asset.tenantId in byTenant;
    if (ptr is null) return false;

    foreach (i, existing; *ptr) {
      if (existing.id == asset.id) {
        (*ptr)[i] = asset;
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
}

unittest {
  auto repo = new MemoryAssetRepository();

  InsightAsset a;
  a.id = "m1";
  a.tenantId = "tenant-m";
  a.name = "Memory Asset";
  a.kind = "story";
  a.sourceSystem = "local";
  a.dimensions = ["region"];
  a.measures = ["revenue"];

  assert(repo.save(a) == "m1");
  assert(repo.findByTenant("tenant-m").length == 1);

  a.name = "Memory Asset Updated";
  assert(repo.update(a));
  assert(repo.findById("tenant-m", "m1").name == "Memory Asset Updated");

  assert(repo.remove("tenant-m", "m1"));
  assert(repo.findByTenant("tenant-m").length == 0);
}
