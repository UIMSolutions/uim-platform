/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage;

import uim.platform.responsibility;

mixin(ShowModule!());

public {
    import uim.platform.responsibility.application.usecases.manage.responsibility_rules;
    import uim.platform.responsibility.application.usecases.manage.team_categories;
    import uim.platform.responsibility.application.usecases.manage.team_types;
    import uim.platform.responsibility.application.usecases.manage.teams;
    import uim.platform.responsibility.application.usecases.manage.team_members;
    import uim.platform.responsibility.application.usecases.manage.member_functions;
    import uim.platform.responsibility.application.usecases.manage.responsibility_contexts;
    import uim.platform.responsibility.application.usecases.manage.responsibility_definitions;
    import uim.platform.responsibility.application.usecases.manage.determine_agents;
    import uim.platform.responsibility.application.usecases.manage.determination_logs;
}
