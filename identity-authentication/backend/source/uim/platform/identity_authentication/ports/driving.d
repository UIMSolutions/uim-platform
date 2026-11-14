/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.driving;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (HTTP, REST, OData, CLI,
/// GUI) depend on this bundle only — never on concrete use cases or repositories.
struct IdentityPorts {
  IAuthenticationUseCase authentication;
  ITokenUseCase tokens;
  IManageSessionsUseCase sessions;
  IManageUsersUseCase users;
  IManageGroupsUseCase groups;
  IManageApplicationsUseCase applications;
  IManagePoliciesUseCase policies;
  IManageRiskRulesUseCase riskRules;
  IManageIdentityProvidersUseCase identityProviders;
  IIdentityStatisticsService statistics;
}
