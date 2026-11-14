/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Strongly typed identifiers of the connectivity aggregates.
/// (TenantId, SubaccountId and UserId come from uim-framework.)
module uim.platform.connectivity.domain.types.ids;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// A destination (named endpoint of a remote service).
struct DestinationId {
  mixin(IdTemplate);
}

/// A registered Cloud Connector (on-premise agent).
struct ConnectorId {
  mixin(IdTemplate);
}

/// A service channel (tunnel) of a Cloud Connector.
struct ChannelId {
  mixin(IdTemplate);
}

/// An access control rule of a Cloud Connector.
struct AccessRuleId {
  mixin(IdTemplate);
}

/// A certificate of the tenant's certificate store.
struct CertificateId {
  mixin(IdTemplate);
}

/// An entry of the connectivity event log.
struct LogEntryId {
  mixin(IdTemplate);
}
