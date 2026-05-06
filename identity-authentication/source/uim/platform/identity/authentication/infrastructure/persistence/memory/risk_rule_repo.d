/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.authentication.infrastructure.persistence.memory.risk_rule;

// import uim.platform.identity.authentication.domain.entities.risk_rule;
// import uim.platform.identity.authentication.domain.types;
// import uim.platform.identity.authentication.domain.ports.repositories.risk_rule;

import uim.platform.identity.authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for risk rule persistence.
class MemoryRiskRuleRepository : TenantRepository!(RiskRule, string), RiskRuleRepository {

  // TODO
}
