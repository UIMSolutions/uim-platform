/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.ports.repositories.situation_actions;
// 
// import uim.platform.situation_automation.domain.types;
// import uim.platform.situation_automation.domain.entities.situation_action;
// 
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:

interface SituationActionRepository {
    SituationAction findById(SituationActionId id);
    SituationAction[] findByTenant(TenantId tenantId);
    SituationAction[] findByType(TenantId tenantId, ActionType type);
    void save(SituationAction a);
    void update(SituationAction a);
    void remove(SituationActionId id);
    long countByTenant(TenantId tenantId);
}
