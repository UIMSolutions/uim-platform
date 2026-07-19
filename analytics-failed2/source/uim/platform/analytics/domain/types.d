module uim.platform.analytics.domain.types;
import uim.platform.analytics;
mixin(ShowModule!());

@safe:  

struct AssetId {
  mixin(IdTemplate);
}

enum StorageBackend {
  memory_,
  files_,
  mongodb_
}
