/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.entities.access_rule;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// An access control rule of a Cloud Connector: which virtual host / port /
/// URL path may be called and where it is mapped to on premise.
struct AccessRule {
  mixin TenantEntity!AccessRuleId;

  ConnectorId connectorId;
  string connectorName;
  string name; /// unique per connector; derived from the mapping if empty
  string description;
  AccessProtocol protocol = AccessProtocol.https;

  string virtualHost; /// as used in destinations
  int virtualPort;
  string internalHost; /// actual on-premise host ("" = virtualHost)
  int internalPort; /// 0 = virtualPort

  string urlPathPrefix = "/"; /// HTTP(S) only
  bool includeSubPaths = true; /// false: the path must match exactly
  AccessPolicy policy = AccessPolicy.allow;
  bool principalPropagation; /// forward the user context
  bool enabled = true;
}
