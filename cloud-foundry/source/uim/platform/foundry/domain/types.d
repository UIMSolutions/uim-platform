/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.types;

import uim.platform.foundry;
mixin(ShowModule!());

@safe:

struct AppId {
  mixin(IdTemplate);
}


struct RouteId {
  mixin(IdTemplate);
}

struct CfDomainId {
  mixin(IdTemplate);
}

struct BuildpackId {
  mixin(IdTemplate);
}
