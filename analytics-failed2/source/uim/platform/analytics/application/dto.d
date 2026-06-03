module uim.platform.analytics.application.dto;

import uim.platform.analytics.domain.types;

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
  AssetId id;
  string name;
  string kind;
  string sourceSystem;
  string[] dimensions;
  string[] measures;
}

struct CommandResult {
  bool success;
  string id;
  string message;

  @property bool hasError() const {
    return !success;
  }
}
