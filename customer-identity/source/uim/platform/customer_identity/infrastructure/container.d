/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.infrastructure.container;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

struct Container {
    ManageCustomersUseCase manageCustomersUseCase;
    ManageCustomerSessionsUseCase manageCustomerSessionsUseCase;
    ManageSocialIdentitiesUseCase manageSocialIdentitiesUseCase;
    ManageConsentRecordsUseCase manageConsentRecordsUseCase;
    ManageAuditLogsUseCase manageAuditLogsUseCase;
    ManageIdentityProvidersUseCase manageIdentityProvidersUseCase;
    ManageScreenSetsUseCase manageScreenSetsUseCase;
    ManageSitePoliciesUseCase manageSitePoliciesUseCase;

    CustomerController customerController;
    CustomerSessionController customerSessionController;
    SocialIdentityController socialIdentityController;
    ConsentRecordController consentRecordController;
    AuditLogController auditLogController;
    IdentityProviderController identityProviderController;
    ScreenSetController screenSetController;
    SitePolicyController sitePolicyController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto customerRepo = new MemoryCustomerRepository();
    auto sessionRepo = new MemoryCustomerSessionRepository();
    auto socialRepo = new MemorySocialIdentityRepository();
    auto consentRepo = new MemoryConsentRecordRepository();
    auto auditRepo = new MemoryAuditLogRepository();
    auto idpRepo = new MemoryIdentityProviderRepository();
    auto screenSetRepo = new MemoryScreenSetRepository();
    auto policyRepo = new MemorySitePolicyRepository();

    // Use Cases
    c.manageCustomersUseCase = new ManageCustomersUseCase(customerRepo);
    c.manageCustomerSessionsUseCase = new ManageCustomerSessionsUseCase(sessionRepo);
    c.manageSocialIdentitiesUseCase = new ManageSocialIdentitiesUseCase(socialRepo);
    c.manageConsentRecordsUseCase = new ManageConsentRecordsUseCase(consentRepo);
    c.manageAuditLogsUseCase = new ManageAuditLogsUseCase(auditRepo);
    c.manageIdentityProvidersUseCase = new ManageIdentityProvidersUseCase(idpRepo);
    c.manageScreenSetsUseCase = new ManageScreenSetsUseCase(screenSetRepo);
    c.manageSitePoliciesUseCase = new ManageSitePoliciesUseCase(policyRepo);

    // Controllers
    c.customerController = new CustomerController(c.manageCustomersUseCase);
    c.customerSessionController = new CustomerSessionController(c.manageCustomerSessionsUseCase);
    c.socialIdentityController = new SocialIdentityController(c.manageSocialIdentitiesUseCase);
    c.consentRecordController = new ConsentRecordController(c.manageConsentRecordsUseCase);
    c.auditLogController = new AuditLogController(c.manageAuditLogsUseCase);
    c.identityProviderController = new IdentityProviderController(c.manageIdentityProvidersUseCase);
    c.screenSetController = new ScreenSetController(c.manageScreenSetsUseCase);
    c.sitePolicyController = new SitePolicyController(c.manageSitePoliciesUseCase);
    c.healthController = new HealthController();

    return c;
}
