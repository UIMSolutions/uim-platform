// import uim.platform.analytics.domain.types;
 uim.platform.analytics.domain.ports.repositories.asset_repository;

import uim.platform.analytics;

mixin(ShowModule!());

@safe:  
interface IAssetRepository {
  AssetId save(InsightAsset asset);
  bool update(InsightAsset asset);
  bool remove(TenantId tenantId, AssetId id);
  InsightAsset findById(TenantId tenantId, AssetId id);
  InsightAsset[] findByTenant(TenantId tenantId);
}
