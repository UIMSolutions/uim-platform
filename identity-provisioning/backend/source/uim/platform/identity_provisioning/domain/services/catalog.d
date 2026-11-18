/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The connector catalogue: which system types exist and which roles they support.
module uim.platform.identity_provisioning.domain.services.catalog;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// All supported connector types.
SystemTypeInfo[] systemTypeCatalog() {
  return [
    SystemTypeInfo("ias", "Identity Authentication", "SAP Cloud Identity Services — Identity Authentication (SCIM 2.0)",
      true, true, true, "https://<tenant>.accounts.ondemand.com", "oauth2ClientCredentials"),
    SystemTypeInfo("ldap", "LDAP Server", "Generic LDAP v3 directory (Active Directory, OpenLDAP)",
      true, true, false, "ldaps://<host>:636", "basic"),
    SystemTypeInfo("sapHr", "SAP HCM", "SAP HCM / ERP HR (on premise, via Cloud Connector)",
      true, false, false, "https://<host>/sap/bc/hcm", "basic"),
    SystemTypeInfo("successFactors", "SAP SuccessFactors", "SAP SuccessFactors Employee Central (OData API)",
      true, true, false, "https://<api-server>.successfactors.com", "oauth2ClientCredentials"),
    SystemTypeInfo("scim", "SCIM System", "Any SCIM 2.0 compatible application",
      true, true, true, "https://<host>/scim/v2", "oauth2ClientCredentials"),
    SystemTypeInfo("csv", "Local CSV File", "Comma separated file (users and groups)",
      true, false, false, "file:///<path>/identities.csv", "none"),
    SystemTypeInfo("azureAd", "Microsoft Entra ID", "Microsoft Entra ID / Azure Active Directory (Graph API)",
      true, true, false, "https://graph.microsoft.com/v1.0", "oauth2ClientCredentials"),
    SystemTypeInfo("custom", "Custom Connector", "Custom connector implementation",
      true, true, true, "https://<host>", "basic"),
  ];
}

/// The catalogue entry of a type.
SystemTypeInfo systemTypeInfo(SystemType type) {
  auto id = enumText(type);
  foreach (info; systemTypeCatalog())
    if (info.id == id)
      return info;
  return SystemTypeInfo.init;
}

/// True if a system of `type` may be used in `role`.
bool supportsRole(SystemType type, SystemRole role) {
  auto info = systemTypeInfo(type);
  final switch (role) {
  case SystemRole.source:
    return info.sourceSupported;
  case SystemRole.target:
    return info.targetSupported;
  case SystemRole.proxy:
    return info.proxySupported;
  }
}

///
unittest {
  assert(systemTypeCatalog().length == 8);
  assert(supportsRole(SystemType.ias, SystemRole.proxy));
  assert(!supportsRole(SystemType.csv, SystemRole.target));
  assert(!supportsRole(SystemType.sapHr, SystemRole.target));
  assert(systemTypeInfo(SystemType.azureAd).name == "Microsoft Entra ID");
}
