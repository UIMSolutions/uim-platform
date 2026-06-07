/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.container;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

struct Container {
    // Use cases
    ManageResponsibilityRulesUseCase       manageRulesUseCase;
    ManageTeamCategoriesUseCase            manageCategoriesUseCase;
    ManageTeamTypesUseCase                 manageTeamTypesUseCase;
    ManageTeamsUseCase                     manageTeamsUseCase;
    ManageTeamMembersUseCase               manageMembersUseCase;
    ManageMemberFunctionsUseCase           manageFunctionsUseCase;
    ManageResponsibilityContextsUseCase    manageContextsUseCase;
    ManageResponsibilityDefinitionsUseCase manageDefinitionsUseCase;
    DetermineAgentsUseCase                 determineAgentsUseCase;
    ManageDeterminationLogsUseCase         manageLogsUseCase;

    // Controllers
    ResponsibilityRuleController       ruleController;
    TeamCategoryController             categoryController;
    TeamTypeController                 teamTypeController;
    TeamController                     teamController;
    TeamMemberController               memberController;
    MemberFunctionController           functionController;
    ResponsibilityContextController    contextController;
    ResponsibilityDefinitionController definitionController;
    AgentDeterminationController       determinationController;
    DeterminationLogController         logController;
    HealthController                   healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto ruleRepo       = new MemoryResponsibilityRuleRepository();
    auto categoryRepo   = new MemoryTeamCategoryRepository();
    auto typeRepo       = new MemoryTeamTypeRepository();
    auto teamRepo       = new MemoryTeamRepository();
    auto memberRepo     = new MemoryTeamMemberRepository();
    auto functionRepo   = new MemoryMemberFunctionRepository();
    auto contextRepo    = new MemoryResponsibilityContextRepository();
    auto definitionRepo = new MemoryResponsibilityDefinitionRepository();
    auto logRepo        = new MemoryDeterminationLogRepository();

    // Domain service
    auto determinator   = new AgentDeterminator(memberRepo, definitionRepo);

    // Use cases
    c.manageRulesUseCase       = new ManageResponsibilityRulesUseCase(ruleRepo);
    c.manageCategoriesUseCase  = new ManageTeamCategoriesUseCase(categoryRepo);
    c.manageTeamTypesUseCase   = new ManageTeamTypesUseCase(typeRepo);
    c.manageTeamsUseCase       = new ManageTeamsUseCase(teamRepo);
    c.manageMembersUseCase     = new ManageTeamMembersUseCase(memberRepo);
    c.manageFunctionsUseCase   = new ManageMemberFunctionsUseCase(functionRepo);
    c.manageContextsUseCase    = new ManageResponsibilityContextsUseCase(contextRepo);
    c.manageDefinitionsUseCase = new ManageResponsibilityDefinitionsUseCase(definitionRepo);
    c.determineAgentsUseCase   = new DetermineAgentsUseCase(contextRepo, ruleRepo, logRepo, determinator);
    c.manageLogsUseCase        = new ManageDeterminationLogsUseCase(logRepo);

    // Controllers
    c.ruleController        = new ResponsibilityRuleController(c.manageRulesUseCase);
    c.categoryController    = new TeamCategoryController(c.manageCategoriesUseCase);
    c.teamTypeController    = new TeamTypeController(c.manageTeamTypesUseCase);
    c.teamController        = new TeamController(c.manageTeamsUseCase);
    c.memberController      = new TeamMemberController(c.manageMembersUseCase);
    c.functionController    = new MemberFunctionController(c.manageFunctionsUseCase);
    c.contextController     = new ResponsibilityContextController(c.manageContextsUseCase);
    c.definitionController  = new ResponsibilityDefinitionController(c.manageDefinitionsUseCase);
    c.determinationController = new AgentDeterminationController(c.determineAgentsUseCase);
    c.logController         = new DeterminationLogController(c.manageLogsUseCase);
    c.healthController      = new HealthController();

    return c;
}
