/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repository implementations (driven adapters of the repository ports).
module uim.platform.identity_authentication.persistence.repositories;

public {
  import uim.platform.identity_authentication.persistence.repositories.users;
  import uim.platform.identity_authentication.persistence.repositories.groups;
  import uim.platform.identity_authentication.persistence.repositories.applications;
  import uim.platform.identity_authentication.persistence.repositories.policies;
  import uim.platform.identity_authentication.persistence.repositories.risk_rules;
  import uim.platform.identity_authentication.persistence.repositories.idp_configs;
  import uim.platform.identity_authentication.persistence.repositories.sessions;
  import uim.platform.identity_authentication.persistence.repositories.tokens;
}
