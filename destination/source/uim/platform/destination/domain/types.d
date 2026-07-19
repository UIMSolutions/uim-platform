/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.types;
import uim.platform.destination;
mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct AuthTokenId {
  mixin(IdTemplate);
}
struct DestinationId {
  mixin(IdTemplate);
}
struct CertificateId {
  mixin(IdTemplate);
}
struct DestinationFragmentId {
  mixin(IdTemplate);
}

struct DestinationLookupId {
  mixin(IdTemplate);
}
