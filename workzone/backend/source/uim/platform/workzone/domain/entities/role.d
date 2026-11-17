/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.role;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A role bundling permissions ("read:workspace", "admin:site", "*:*").
struct Role {
  mixin TenantEntity!RoleId;

  string name; /// unique per tenant
  string description;
  string[] permissions;
  bool isDefault; /// assigned to new user profiles
  bool predefined; /// installed by the seed, protected
}
