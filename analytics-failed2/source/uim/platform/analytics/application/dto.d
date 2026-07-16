module uim.platform.analytics.application.dto;

import uim.platform.analytics;

mixin(ShowModule!());

@safe:  

struct CreateAssetRequest {
  TenantId tenantId;
  string name;
  string kind;
  string sourceSystem;
  string[] dimensions;
  string[] measures;
}

struct UpdateAssetRequest {
  TenantId tenantId;
  AssetId assetId;
  string name;
  string kind;
  string sourceSystem;
  string[] dimensions;
  string[] measures;
}
