module uim.platform.analytics.domain.ports.repositories.asset_repository;

// import uim.platform.analytics.domain.entities.insight_asset;
// import uim.platform.analytics.domain.types;
import uim.platform.analytics;
mixin(ShowModule!());

@safe:  
interface AssetRepository {
  AssetId save(InsightAsset asset);
  bool update(InsightAsset asset);
  bool remove(TenantId tenantId, AssetId id);
  InsightAsset findById(TenantId tenantId, AssetId id);
  InsightAsset[] findByTenant(TenantId tenantId);
}
