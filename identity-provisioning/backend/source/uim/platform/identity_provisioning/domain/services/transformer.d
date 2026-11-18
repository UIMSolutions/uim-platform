/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Transformation engine: evaluates filter conditions and attribute mappings.
/// Pure functions — no repositories, no I/O.
module uim.platform.identity_provisioning.domain.services.transformer;

import std.uni : toLower, toUpper;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// True if the transformation applies to entities of `type`.
bool inScope(EntityScope scope_, EntityType type) {
  return scope_ == EntityScope.all || (scope_ == EntityScope.user && type == EntityType.user)
    || (scope_ == EntityScope.group && type == EntityType.group);
}

/// Evaluate one condition (string comparison, case-insensitive).
bool conditionHolds(const EntityCondition c, const Attribute[] attributes) {
  auto actual = attributeValue(attributes, c.attribute).toLower;
  auto expected = c.value.toLower;
  final switch (c.operator_) {
  case ConditionOperator.equals:
    return actual == expected;
  case ConditionOperator.notEquals:
    return actual != expected;
  case ConditionOperator.contains:
    return actual.canFind(expected);
  case ConditionOperator.startsWith:
    return actual.startsWith(expected);
  case ConditionOperator.endsWith:
    return actual.endsWith(expected);
  case ConditionOperator.present:
    return actual.length > 0;
  case ConditionOperator.absent:
    return actual.length == 0;
  }
}

/// "department equals 'IT'".
string conditionText(const EntityCondition c) {
  auto op = enumText(c.operator_);
  return c.operator_ == ConditionOperator.present || c.operator_ == ConditionOperator.absent
    ? c.attribute ~ " " ~ op : c.attribute ~ " " ~ op ~ " '" ~ c.value ~ "'";
}

/// Value of one mapping for an entity.
string mappedValue(const AttributeMapping m, const Attribute[] attributes) {
  if (m.function_ == MappingFunction.constant)
    return m.defaultValue;
  auto v = m.sourcePath.length ? attributeValue(attributes, m.sourcePath) : "";
  if (v.length == 0)
    v = m.defaultValue;
  final switch (m.function_) {
  case MappingFunction.none, MappingFunction.constant:
    return v;
  case MappingFunction.lowerCase:
    return v.toLower;
  case MappingFunction.upperCase:
    return v.toUpper;
  case MappingFunction.trim:
    return v.strip;
  }
}

/// Apply one transformation. Inactive or out-of-scope transformations pass the
/// attributes through unchanged; without mappings all attributes pass through.
TransformationResult transform(const Transformation t, EntityType type, const Attribute[] attributes) {
  TransformationResult r;
  foreach (a; attributes)
    r.attributes ~= Attribute(a.key, a.value);
  if (!t.active || !inScope(t.scope_, type))
    return r;

  foreach (c; t.conditions)
    if (!conditionHolds(c, attributes)) {
      r.accepted = false;
      r.reason = "filtered by " ~ t.name ~ ": " ~ conditionText(c);
      return r;
    }
  if (t.mappings.length == 0)
    return r;

  Attribute[] mapped;
  foreach (m; t.mappings) {
    auto v = mappedValue(m, attributes);
    if (v.length == 0 && m.mandatory) {
      r.accepted = false;
      r.failed = true;
      r.reason = t.name ~ ": mandatory attribute '" ~ m.targetPath ~ "' is empty (source '" ~ m.sourcePath ~ "')";
      return r;
    }
    if (v.length > 0)
      mapped = withAttribute(mapped, m.targetPath, v);
  }
  r.attributes = mapped;
  return r;
}

/// Apply transformations in `sequence` order (then by name); stops at the first
/// rejection.
TransformationResult transformAll(Transformation[] transformations, EntityType type, const Attribute[] attributes) {
  auto ordered = transformations.dup;
  ordered.sort!((a, b) => a.sequence != b.sequence ? a.sequence < b.sequence : a.name < b.name);
  TransformationResult r;
  foreach (a; attributes)
    r.attributes ~= Attribute(a.key, a.value);
  foreach (t; ordered) {
    r = transform(t, type, r.attributes);
    if (!r.accepted)
      return r;
  }
  return r;
}

/// Validate mappings and conditions of a transformation.
void validateRules(const AttributeMapping[] mappings, const EntityCondition[] conditions) {
  string[] targets;
  foreach (m; mappings) {
    validate(m.targetPath.strip.length > 0, "Every mapping needs a targetPath");
    validate(m.function_ == MappingFunction.constant || m.sourcePath.strip.length > 0 || m.defaultValue.length > 0,
      "Mapping to '" ~ m.targetPath ~ "' needs a sourcePath or a defaultValue");
    validate(m.function_ != MappingFunction.constant || m.defaultValue.length > 0,
      "Constant mapping to '" ~ m.targetPath ~ "' needs a defaultValue");
    validate(!targets.canFind(m.targetPath), "Target attribute '" ~ m.targetPath ~ "' is mapped twice");
    targets ~= m.targetPath;
  }
  foreach (c; conditions) {
    validate(c.attribute.strip.length > 0, "Every condition needs an attribute");
    validate(c.operator_ == ConditionOperator.present || c.operator_ == ConditionOperator.absent || c.value.length > 0,
      "Condition on '" ~ c.attribute ~ "' needs a value");
  }
}

///
unittest {
  auto ada = [Attribute("userName", "Ada.Lovelace"), Attribute("email", "ada@example.com"),
    Attribute("department", "IT")];

  Transformation t;
  t.name = "IAS write";
  t.mappings = [
    AttributeMapping("userName", "userName", MappingFunction.lowerCase),
    AttributeMapping("email", "emails[0].value"),
    AttributeMapping("", "userType", MappingFunction.constant, "employee"),
    AttributeMapping("costCenter", "costCenter", MappingFunction.none, "CC-100"),
  ];
  auto r = transform(t, EntityType.user, ada);
  assert(r.accepted && attributeValue(r.attributes, "userName") == "ada.lovelace");
  assert(attributeValue(r.attributes, "emails[0].value") == "ada@example.com");
  assert(attributeValue(r.attributes, "userType") == "employee" && attributeValue(r.attributes, "costCenter") == "CC-100");
  assert(!hasAttribute(r.attributes, "department")); // mapped attributes only

  // conditions filter, mandatory mappings fail
  t.conditions = [EntityCondition("department", ConditionOperator.equals, "it")];
  assert(transform(t, EntityType.user, ada).accepted);
  t.conditions = [EntityCondition("department", ConditionOperator.equals, "HR")];
  auto filtered = transform(t, EntityType.user, ada);
  assert(!filtered.accepted && !filtered.failed && filtered.reason.canFind("department equals 'HR'"));
  t.conditions = null;
  t.mappings ~= AttributeMapping("phone", "phoneNumbers[0].value", MappingFunction.none, "", true);
  auto failed = transform(t, EntityType.user, ada);
  assert(failed.failed && !failed.accepted);

  // scope and inactive transformations pass through
  t.scope_ = EntityScope.group;
  assert(transform(t, EntityType.user, ada).attributes.length == 3);
  t.scope_ = EntityScope.all;
  t.active = false;
  assert(transform(t, EntityType.user, ada).accepted);

  // chain in sequence order
  Transformation read, write;
  read.name = "read";
  read.sequence = 1;
  read.mappings = [AttributeMapping("email", "mail"), AttributeMapping("userName", "login", MappingFunction.upperCase)];
  write.name = "write";
  write.sequence = 2;
  write.mappings = [AttributeMapping("mail", "email"), AttributeMapping("login", "userName")];
  auto chained = transformAll([write, read], EntityType.user, ada);
  assert(attributeValue(chained.attributes, "userName") == "ADA.LOVELACE" && attributeValue(chained.attributes, "email") == "ada@example.com");

  bool rejected;
  try validateRules([AttributeMapping("a", "x"), AttributeMapping("b", "x")], null);
  catch (ProvisioningValidationException) rejected = true;
  assert(rejected);
  assert(conditionHolds(EntityCondition("email", ConditionOperator.endsWith, "@EXAMPLE.com"), ada));
  assert(conditionHolds(EntityCondition("phone", ConditionOperator.absent), ada));
}
