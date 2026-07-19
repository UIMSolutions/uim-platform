/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.types;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:

/// Unique identifier for a private endpoint.
struct PrivateEndpointId {
  mixin(IdTemplate);
}


