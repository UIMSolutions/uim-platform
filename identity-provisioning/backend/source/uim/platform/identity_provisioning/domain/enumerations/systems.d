/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.enumerations.systems;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Connector type of a source, target or proxy system.
/// (Older payloads with "sap_hr" / "azure_ad" are accepted, see helpers.enums.)
enum SystemType {
  ias, /// SAP Cloud Identity Services — Identity Authentication
  ldap, /// generic LDAP directory
  sapHr, /// SAP HCM (on premise)
  successFactors, /// SAP SuccessFactors Employee Central
  scim, /// any SCIM 2.0 compatible system
  csv, /// comma separated file
  azureAd, /// Microsoft Entra ID (Azure AD)
  custom, /// custom connector
}

/// Operational status of a system connection.
enum SystemStatus {
  configuring, /// created, not yet tested
  active, /// connection tested, used by jobs
  inactive, /// switched off by an administrator
  error, /// last connection test failed
}

/// Role of a system in the provisioning pipeline.
enum SystemRole {
  source,
  target,
  proxy,
}

/// How the connector authenticates against the system.
enum AuthenticationType {
  none,
  basic, /// user + password
  oauth2ClientCredentials, /// client id (user) + client secret (password)
  certificate, /// X.509 client certificate (configured in the connector)
}
