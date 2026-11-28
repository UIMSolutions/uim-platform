/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A role of the built-in login: a named set of scopes assigned to users.
/// The built-in roles (Viewer, Operator, Developer, Manager, Administrator)
/// mirror the role templates of xs-security.json; they cannot be deleted
/// and the Administrator role always keeps all scopes.
module uim.platform.ai_launchpad.domain.entities.role;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Role {
  mixin TenantEntity!RoleId;

  string name;
  string description;
  string[] scopes;
  bool builtIn;

  bool grants(string scope_) const {
    return scopes.canFind(scope_);
  }

  void validate() const {
    requireId(id.value, "Role ID");
    requireText(name, "Role name");
    requireMaxLength(name, 100, "Role name");
    requireMaxLength(description, 1000, "Description");
    if (scopes.length == 0)
      throw AilpException.invalid("A role needs at least one scope");
    normalizeScopes(scopes);
  }
}

///
unittest {
  Role r;
  r.id = RoleId("auditor");
  r.name = "Auditor";
  assert(failsWith(AilpErrorKind.invalid, () { r.validate(); }));
  r.scopes = ["Read", "Admin"];
  r.validate();
  assert(r.grants("Admin") && !r.grants("Manage"));
}
