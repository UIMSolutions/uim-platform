/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
