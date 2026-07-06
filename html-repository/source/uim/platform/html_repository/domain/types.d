/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.types;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
// ID aliases
struct HtmlAppId {
  mixin(IdTemplate);
}

struct AppVersionId {
  mixin(IdTemplate);
}

struct AppFileId {
  mixin(IdTemplate);
}

struct DeploymentRecordId {
  mixin(IdTemplate);
}

struct AppRouteId {
  mixin(IdTemplate);
}

struct ContentCacheId {
  mixin(IdTemplate);
}


// struct SpaceId {
//     mixin(IdTemplate);

// }