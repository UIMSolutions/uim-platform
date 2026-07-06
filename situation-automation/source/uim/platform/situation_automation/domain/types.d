/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.types;

import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
// ID aliases
struct SituationTemplateId  {
    mixin(IdTemplate);
}
struct SituationInstanceId  {
    mixin(IdTemplate);
}
struct SituationActionId  {
    mixin(IdTemplate);
}
struct AutomationRuleId  {
    mixin(IdTemplate);
}
struct EntityTypeId  {
    mixin(IdTemplate);
}
struct DataContextId  {
    mixin(IdTemplate);
}
struct NotificationId  {
    mixin(IdTemplate);
}
struct DashboardId  {
    mixin(IdTemplate);
}
