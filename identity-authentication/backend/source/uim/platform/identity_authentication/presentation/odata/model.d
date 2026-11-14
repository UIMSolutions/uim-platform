/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// EDM model of the Identity Authentication OData v4 service.
module uim.platform.identity_authentication.presentation.odata.model;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Primitive EDM types used by the service.
enum Edm : string {
  string_ = "Edm.String",
  int32 = "Edm.Int32",
  int64 = "Edm.Int64",
  boolean = "Edm.Boolean",
  dateTimeOffset = "Edm.DateTimeOffset",
}

/// A structural property of an entity or complex type.
struct ODataPropertyDef {
  string name;
  string type; /// Edm.* or a qualified complex type name
  bool nullable = true;
  bool collection;
  string label; /// Common.Label for Fiori

  string edmType() const {
    return collection ? "Collection(" ~ type ~ ")" : type;
  }
}

/// A complex type (no key).
struct ODataComplexTypeDef {
  string name;
  ODataPropertyDef[] properties;
}

/// Entity type + entity set (1:1 in this service).
struct ODataEntitySetDef {
  string name; /// entity set name, e.g. "Devices"
  string entityType; /// entity type name, e.g. "Device"
  string key = "id";
  ODataPropertyDef[] properties;
  bool insertable;
  bool updatable;
  bool deletable;
  bool singleton; /// exposed as <Singleton> instead of <EntitySet>

  bool hasProperty(string propertyName) const {
    return properties.any!(p => p.name == propertyName);
  }

  /// Names of the properties with the given EDM type.
  string[] propertiesOfType(string edmType) const {
    string[] names;
    foreach (p; properties)
      if (p.type == edmType)
        names ~= p.name;
    return names;
  }
}

/// An unbound action (POST <service>/<Name> with a JSON parameter object).
struct ODataActionDef {
  string name;
  ODataPropertyDef[] parameters;
  string returnType; /// qualified type name ("" = no return value)
  string returnEntitySet; /// entity set of the returned entity (ActionImport EntitySet)
}

/// The whole EDM model of a service.
class ODataServiceModel {
  string namespace_;
  string containerName;
  ODataEntitySetDef[] entitySets;
  ODataComplexTypeDef[] complexTypes;
  ODataActionDef[] actions;

  this(string namespace_, string containerName) {
    this.namespace_ = namespace_;
    this.containerName = containerName;
  }

  /// True if an entity set or singleton with this name exists.
  bool has(string name) const {
    return entitySets.any!(s => s.name == name);
  }

  /// The entity set or singleton with this name (ODataEntitySetDef.init if unknown).
  const(ODataEntitySetDef) find(string name) const {
    foreach (s; entitySets)
      if (s.name == name)
        return s;
    return ODataEntitySetDef.init;
  }

  bool hasAction(string name) const {
    return actions.any!(a => a.name == name);
  }

  const(ODataActionDef) findAction(string name) const {
    foreach (a; actions)
      if (a.name == name)
        return a;
    return ODataActionDef.init;
  }

  string qualified(string typeName) const {
    return namespace_ ~ "." ~ typeName;
  }
}

private ODataPropertyDef p(string name, Edm type, string label, bool nullable = true) {
  return ODataPropertyDef(name, cast(string) type, nullable, false, label);
}

private ODataPropertyDef[] tenantEntityProperties() {
  return [
    p("id", Edm.string_, "ID", false),
    p("tenantId", Edm.string_, "Tenant"),
    p("createdBy", Edm.string_, "Created By"),
    p("createdAt", Edm.dateTimeOffset, "Created At"),
    p("updatedBy", Edm.string_, "Changed By"),
    p("updatedAt", Edm.dateTimeOffset, "Changed At"),
  ];
}

/// Namespace of the identity authentication EDM model.
enum identityNamespace = "uim.ias";

/// The EDM model of the identity authentication OData service. Secrets
/// (password hashes, MFA seeds, client secret hashes, token values) are never
/// part of the model; "password" (Users), "clientSecret" (Applications,
/// IdentityProviders) are write-only and always read back as null — except the
/// generated client secret in the POST Applications / RotateClientSecret response.
ODataServiceModel identityODataModel() {
  enum ns = identityNamespace;
  auto m = new ODataServiceModel(ns, "IdentityAuthenticationService");

  ODataEntitySetDef users = {
    name: "Users", entityType: "User", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("userName", Edm.string_, "User Name"),
      p("email", Edm.string_, "E-Mail"),
      p("firstName", Edm.string_, "First Name"),
      p("lastName", Edm.string_, "Last Name"),
      p("displayName", Edm.string_, "Name"),
      p("status", Edm.string_, "Status"),
      p("mfaType", Edm.string_, "Second Factor"),
      p("phoneNumber", Edm.string_, "Phone"),
      p("externalIdpId", Edm.string_, "External IdP"),
      p("globalUserId", Edm.string_, "Global User ID"),
      p("groupCount", Edm.int32, "Groups"),
      p("failedLoginAttempts", Edm.int32, "Failed Logins"),
      p("lastLoginAt", Edm.dateTimeOffset, "Last Login"),
      p("passwordChangedAt", Edm.dateTimeOffset, "Password Changed"),
      p("password", Edm.string_, "Initial Password"),
    ]
  };
  m.entitySets ~= users;

  ODataEntitySetDef groups = {
    name: "Groups", entityType: "Group", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("memberCount", Edm.int32, "Members"),
      p("memberUserIds", Edm.string_, "Member IDs"),
    ]
  };
  m.entitySets ~= groups;

  ODataEntitySetDef applications = {
    name: "Applications", entityType: "Application", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("protocol", Edm.string_, "Protocol"),
      p("clientId", Edm.string_, "Client ID"),
      p("clientSecret", Edm.string_, "Client Secret"),
      p("redirectUris", Edm.string_, "Redirect URIs"),
      p("allowedScopes", Edm.string_, "Allowed Scopes"),
      p("samlEntityId", Edm.string_, "SAML Entity ID"),
      p("samlAcsUrl", Edm.string_, "SAML ACS URL"),
      p("samlMetadataUrl", Edm.string_, "SAML Metadata URL"),
      p("active", Edm.boolean, "Active"),
    ]
  };
  m.entitySets ~= applications;

  ODataEntitySetDef policies = {
    name: "Policies", entityType: "Policy", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("description", Edm.string_, "Description"),
      p("rules", Edm.string_, "Rules"),
      p("applicationIds", Edm.string_, "Applications"),
      p("active", Edm.boolean, "Active"),
    ]
  };
  m.entitySets ~= policies;

  ODataEntitySetDef riskRules = {
    name: "RiskRules", entityType: "RiskRule", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("conditions", Edm.string_, "Conditions"),
      p("riskLevel", Edm.string_, "Risk Level"),
      p("requiredMfa", Edm.string_, "Required MFA"),
      p("denyAccess", Edm.boolean, "Deny Access"),
      p("active", Edm.boolean, "Active"),
    ]
  };
  m.entitySets ~= riskRules;

  ODataEntitySetDef idps = {
    name: "IdentityProviders", entityType: "IdentityProvider", insertable: true, updatable: true, deletable: true,
    properties: tenantEntityProperties() ~ [
      p("name", Edm.string_, "Name"),
      p("idpType", Edm.string_, "Type"),
      p("metadataUrl", Edm.string_, "Metadata URL"),
      p("authorizationEndpoint", Edm.string_, "Authorization Endpoint"),
      p("tokenEndpoint", Edm.string_, "Token Endpoint"),
      p("userInfoEndpoint", Edm.string_, "UserInfo Endpoint"),
      p("clientId", Edm.string_, "Client ID"),
      p("clientSecret", Edm.string_, "Client Secret"),
      p("domainHints", Edm.string_, "E-Mail Domains"),
      p("isDefault", Edm.boolean, "Default"),
      p("active", Edm.boolean, "Active"),
    ]
  };
  m.entitySets ~= idps;

  ODataEntitySetDef sessions = {
    name: "Sessions", entityType: "Session", deletable: true,
    properties: tenantEntityProperties() ~ [
      p("userId", Edm.string_, "User"),
      p("applicationId", Edm.string_, "Application"),
      p("authMethod", Edm.string_, "Authentication Method"),
      p("mfaUsed", Edm.string_, "Second Factor"),
      p("ipAddress", Edm.string_, "IP Address"),
      p("userAgent", Edm.string_, "User Agent"),
      p("riskLevel", Edm.string_, "Risk Level"),
      p("expiresAt", Edm.dateTimeOffset, "Expires At"),
      p("revoked", Edm.boolean, "Revoked"),
      p("state", Edm.string_, "State"),
    ]
  };
  m.entitySets ~= sessions;

  ODataEntitySetDef tokens = {
    name: "Tokens", entityType: "Token", deletable: true,
    properties: tenantEntityProperties() ~ [
      p("userId", Edm.string_, "User"),
      p("applicationId", Edm.string_, "Application"),
      p("sessionId", Edm.string_, "Session"),
      p("tokenType", Edm.string_, "Type"),
      p("scopes", Edm.string_, "Scopes"),
      p("issuedAt", Edm.dateTimeOffset, "Issued At"),
      p("expiresAt", Edm.dateTimeOffset, "Expires At"),
      p("revoked", Edm.boolean, "Revoked"),
      p("state", Edm.string_, "State"),
    ]
  };
  m.entitySets ~= tokens;

  ODataEntitySetDef statistics = {
    name: "Statistics", entityType: "Statistic", key: "tenantId", singleton: true,
    properties: [
      p("tenantId", Edm.string_, "Tenant", false),
      p("users", Edm.int32, "Users"),
      p("activeUsers", Edm.int32, "Active Users"),
      p("lockedUsers", Edm.int32, "Locked Users"),
      p("inactiveUsers", Edm.int32, "Inactive Users"),
      p("pendingUsers", Edm.int32, "Pending Users"),
      p("mfaUsers", Edm.int32, "Users with MFA"),
      p("mfaCoverage", Edm.int32, "MFA Coverage (%)"),
      p("usersWithFailedLogins", Edm.int32, "Users with Failed Logins"),
      p("groups", Edm.int32, "Groups"),
      p("applications", Edm.int32, "Applications"),
      p("activeApplications", Edm.int32, "Active Applications"),
      p("policies", Edm.int32, "Policies"),
      p("riskRules", Edm.int32, "Risk Rules"),
      p("identityProviders", Edm.int32, "Identity Providers"),
      p("sessions", Edm.int32, "Sessions"),
      p("activeSessions", Edm.int32, "Active Sessions"),
      p("tokens", Edm.int32, "Tokens"),
      p("activeTokens", Edm.int32, "Active Tokens"),
      p("lastLoginAt", Edm.dateTimeOffset, "Last Login"),
    ]
  };
  m.entitySets ~= statistics;

  // ── complex results of actions ──────────────────────────────────────────
  m.complexTypes ~= ODataComplexTypeDef("MfaEnrollment", [
      p("id", Edm.string_, "User"), p("mfaType", Edm.string_, "Second Factor"),
      p("secret", Edm.string_, "Secret"), p("provisioningUri", Edm.string_, "Provisioning URI")
    ]);
  m.complexTypes ~= ODataComplexTypeDef("AccessDecision", [
      p("granted", Edm.boolean, "Granted"), p("denyingPolicies", Edm.string_, "Denying Policies")
    ]);
  m.complexTypes ~= ODataComplexTypeDef("RiskAssessment", [
      p("riskLevel", Edm.string_, "Risk Level"), p("requiredMfa", Edm.string_, "Required MFA"),
      p("denied", Edm.boolean, "Denied"), p("triggeredRules", Edm.string_, "Triggered Rules")
    ]);
  m.complexTypes ~= ODataComplexTypeDef("PurgeResult", [
      p("sessions", Edm.int32, "Sessions Removed"), p("tokens", Edm.int32, "Tokens Removed")
    ]);

  // ── unbound actions ─────────────────────────────────────────────────────
  auto id = [p("id", Edm.string_, "ID", false)];
  void entityAction(string name, string entityType, string set, ODataPropertyDef[] extra = null) {
    m.actions ~= ODataActionDef(name, id ~ extra, ns ~ "." ~ entityType, set);
  }

  void complexAction(string name, string complexType, ODataPropertyDef[] parameters) {
    m.actions ~= ODataActionDef(name, parameters, ns ~ "." ~ complexType, "");
  }

  entityAction("SetUserStatus", "User", "Users", [p("status", Edm.string_, "Status", false)]);
  entityAction("ResetPassword", "User", "Users", [p("newPassword", Edm.string_, "New Password", false)]);
  entityAction("DisableMfa", "User", "Users");
  entityAction("RevokeUserSessions", "User", "Users");
  complexAction("EnrollMfa", "MfaEnrollment", id ~ [p("mfaType", Edm.string_, "Second Factor", false)]);
  entityAction("AddGroupMember", "Group", "Groups", [p("userId", Edm.string_, "User", false)]);
  entityAction("RemoveGroupMember", "Group", "Groups", [p("userId", Edm.string_, "User", false)]);
  entityAction("RotateClientSecret", "Application", "Applications");
  complexAction("EvaluateAccess", "AccessDecision", [
      p("applicationId", Edm.string_, "Application", false), p("userId", Edm.string_, "User", false),
      p("ipAddress", Edm.string_, "IP Address"), p("authMethod", Edm.string_, "Authentication Method"),
      p("mfaUsed", Edm.boolean, "MFA Used")
    ]);
  complexAction("AssessRisk", "RiskAssessment", [
      p("userId", Edm.string_, "User", false), p("ipAddress", Edm.string_, "IP Address"),
      p("userAgent", Edm.string_, "User Agent")
    ]);
  complexAction("PurgeExpired", "PurgeResult", null);

  return m;
}

///
unittest {
  mixin(ShowTest!("identityODataModel"));

  auto m = identityODataModel();
  assert(m.has("Users") && m.has("Tokens") && m.find("Statistics").singleton);
  assert(m.find("Users").hasProperty("email"));
  assert(!m.find("Users").hasProperty("passwordHash") && !m.find("Users").hasProperty("mfaSecret"));
  assert(!m.find("Sessions").insertable && m.find("Sessions").deletable);
  assert(m.hasAction("RotateClientSecret") && m.findAction("EnrollMfa").returnEntitySet == "");
  assert(m.findAction("EvaluateAccess").parameters.length == 5);
}
