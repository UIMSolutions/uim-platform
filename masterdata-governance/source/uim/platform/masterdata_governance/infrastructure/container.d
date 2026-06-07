/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.infrastructure.container;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

struct Container {
    ManageBusinessPartnersUseCase manageBusinessPartnersUseCase;
    ManageChangeRequestsUseCase manageChangeRequestsUseCase;
    ManageDataQualityRulesUseCase manageDataQualityRulesUseCase;
    ManageDataQualityScoresUseCase manageDataQualityScoresUseCase;
    ManageReplicationsUseCase manageReplicationsUseCase;

    BusinessPartnerController businessPartnerController;
    ChangeRequestController changeRequestController;
    DataQualityRuleController dataQualityRuleController;
    DataQualityScoreController dataQualityScoreController;
    ReplicationController replicationController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto businessPartnerRepo = new MemoryBusinessPartnerRepository();
    auto changeRequestRepo = new MemoryChangeRequestRepository();
    auto dataQualityRuleRepo = new MemoryDataQualityRuleRepository();
    auto dataQualityScoreRepo = new MemoryDataQualityScoreRepository();
    auto replicationRepo = new MemoryReplicationRepository();

    // Use Cases
    c.manageBusinessPartnersUseCase = new ManageBusinessPartnersUseCase(businessPartnerRepo);
    c.manageChangeRequestsUseCase = new ManageChangeRequestsUseCase(changeRequestRepo);
    c.manageDataQualityRulesUseCase = new ManageDataQualityRulesUseCase(dataQualityRuleRepo);
    c.manageDataQualityScoresUseCase = new ManageDataQualityScoresUseCase(dataQualityScoreRepo);
    c.manageReplicationsUseCase = new ManageReplicationsUseCase(replicationRepo);

    // Controllers
    c.businessPartnerController = new BusinessPartnerController(c.manageBusinessPartnersUseCase);
    c.changeRequestController = new ChangeRequestController(c.manageChangeRequestsUseCase);
    c.dataQualityRuleController = new DataQualityRuleController(c.manageDataQualityRulesUseCase);
    c.dataQualityScoreController = new DataQualityScoreController(c.manageDataQualityScoresUseCase);
    c.replicationController = new ReplicationController(c.manageReplicationsUseCase);
    c.healthController = new HealthController();

    return c;
}
