/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.domain.types;
/// Unique identifier type aliases for type safety.
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:

/// Unique identifier type aliases for type safety.
struct GroupId {
  mixin(IdTemplate);
}

struct SchemaId {
  mixin(IdTemplate);
}

struct AttributeId {
  mixin(IdTemplate);
}

struct ApiClientId {
  mixin(IdTemplate);
}

struct AuditEventId {
  mixin(IdTemplate);
}

struct PasswordPolicyId {
  mixin(IdTemplate);
}