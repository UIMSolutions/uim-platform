/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Value objects embedded in the aggregates (exchanged as OData complex types)
/// and the reference data of the service.
module uim.platform.identity_provisioning.domain.types.values;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A named attribute or connector property ("email" = "ada@example.com",
/// "ldap.user.filter" = "(objectClass=person)").
struct Attribute {
  string key;
  string value;
}

/// Value of `key` ("" if missing).
string attributeValue(const Attribute[] attributes, string key) {
  foreach (a; attributes)
    if (a.key == key)
      return a.value;
  return "";
}

/// True if `key` exists with a non-empty value.
bool hasAttribute(const Attribute[] attributes, string key) {
  return attributeValue(attributes, key).length > 0;
}

/// A copy of `attributes` with `key` set to `value` (appended if new).
Attribute[] withAttribute(const Attribute[] attributes, string key, string value) {
  Attribute[] result;
  bool found;
  foreach (a; attributes) {
    if (a.key == key) {
      result ~= Attribute(key, value);
      found = true;
    } else
      result ~= Attribute(a.key, a.value);
  }
  if (!found)
    result ~= Attribute(key, value);
  return result;
}

/// Maps one source attribute to one target attribute.
struct AttributeMapping {
  string sourcePath; /// attribute of the incoming entity ("" for constants)
  string targetPath; /// attribute written to the target
  MappingFunction function_ = MappingFunction.none;
  string defaultValue; /// used when the source value is empty (and by "constant")
  bool mandatory; /// entity fails if the result is empty
}

/// Entity filter: an entity is provisioned only if all conditions hold.
struct EntityCondition {
  string attribute;
  ConditionOperator operator_ = ConditionOperator.equals;
  string value;
}

/// The connection settings of a system, handed to the connector gateway.
struct ConnectionSettings {
  string systemName;
  SystemType systemType;
  string url;
  AuthenticationType authenticationType;
  string user;
  string password;
  Attribute[] properties;
}

/// Outcome of a connection test.
struct ConnectionTestResult {
  bool success;
  string message;
  int latencyMs;
}

/// An identity as read from a source system (before transformations).
struct SourceIdentity {
  string externalId; /// stable id in the source system
  EntityType entityType = EntityType.user;
  string name; /// userName / group display name
  Attribute[] attributes;
}

/// Result of applying the transformations to one identity.
struct TransformationResult {
  bool accepted = true; /// false: filtered out by a condition, or failed
  bool failed; /// true: a mandatory attribute is missing
  string reason;
  Attribute[] attributes;
}

/// A planned write to a target system (output of the provisioning planner).
struct PlannedOperation {
  OperationType operation = OperationType.skip;
  EntityType entityType = EntityType.user;
  string externalId;
  string name;
  Attribute[] attributes;
  string checksum;
  string reason;
  ProvisionedEntityId existingId; /// update / delete / skip
  string targetId; /// id in the target system (update / delete)
}

/// A connector type of the catalogue (read-only OData entity set "SystemTypes").
struct SystemTypeInfo {
  string id; /// SystemType name, e.g. "ias"
  string name;
  string description;
  bool sourceSupported;
  bool targetSupported;
  bool proxySupported;
  string urlPattern; /// e.g. "https://<tenant>.accounts.ondemand.com"
  string defaultAuthentication;
}

///
unittest {
  auto attrs = [Attribute("email", "ada@example.com"), Attribute("active", "")];
  assert(attributeValue(attrs, "email") == "ada@example.com");
  assert(!hasAttribute(attrs, "active") && !hasAttribute(attrs, "x"));
  auto changed = withAttribute(attrs, "active", "true");
  assert(attributeValue(changed, "active") == "true" && changed.length == 2);
  assert(withAttribute(attrs, "department", "IT").length == 3);
}
