/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.types;
import uim.platform.connectivity;
mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct DestinationId {
  mixin(IdTemplate);
}

struct ConnectorId {
  mixin(IdTemplate);
}

struct ChannelId {
  mixin(IdTemplate);
}

struct RuleId {
  mixin(IdTemplate);
}

struct CertificateId {
  mixin(IdTemplate);
}

struct ConnectivityLogEntryId {
  mixin(IdTemplate);
}


struct SourceId {
  mixin(IdTemplate);
}
