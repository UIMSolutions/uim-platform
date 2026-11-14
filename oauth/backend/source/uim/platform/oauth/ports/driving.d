/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The complete set of driving ports — what every adapter (OAuth endpoints,
/// REST, OData, CLI, GUI, workers) may call.
module uim.platform.oauth.ports.driving;

import uim.platform.oauth;

mixin(ShowModule!());

@safe:

struct OAuthPorts {
  IManageClients clients;
  IManageScopes scopes;
  IManageBrandings brandings;
  IManageTokens tokens;
  IAuthenticateClients authentication;
  IAuthorize authorization;
  IIssueTokens issuer;
  IIntrospectTokens introspection;
  IOAuthStatisticsService statistics;
}
