module uim.platform.analytics.domain.types;

alias TenantId = string;
alias AssetId = string;

enum StorageBackend {
  memory_,
  files_,
  mongodb_
}
