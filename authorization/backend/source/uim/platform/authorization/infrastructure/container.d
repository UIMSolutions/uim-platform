/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.authorization.infrastructure.container;

import uim.platform.authorization;
import uim.platform.authorization.presentation.odata.engine : authorizationEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class AuthorizationContainer {
  AuthorizationConfig config;
  IDocumentStore store;
  AuthorizationPorts ports;
  ODataEngine engine; /// drives OData, JSON API, REST, CLI and GUI

  /// store may be injected (tests); default follows the configuration.
  this(AuthorizationConfig config, IDocumentStore store = null) {
    this.config = config;
    this.store = store !is null ? store : createDocumentStore(config.storageSettings);

    // driven adapters
    auto applications = new ApplicationRepository(this.store);
    auto apis = new ApplicationApiRepository(this.store);
    auto policies = new PolicyRepository(this.store);
    auto assignments = new AssignmentRepository(this.store);
    auto decisions = new DecisionRepository(this.store);
    auto publisher = new LogDecisionPublisher;

    // application
    auto manageApplications = new ManageApplicationsUseCase(applications, apis, policies, assignments);
    ports.applications = manageApplications;
    ports.apis = new ManageApplicationApisUseCase(apis, applications);
    ports.policies = new ManagePoliciesUseCase(policies, applications, assignments);
    ports.assignments = new ManageAssignmentsUseCase(assignments, policies);
    ports.evaluation = new EvaluateAuthorizationUseCase(manageApplications, policies, assignments, decisions,
      publisher, new PolicyEvaluator, config.recordDecisions);
    ports.decisions = new QueryDecisionsUseCase(decisions);
    ports.statistics = new StatisticsService(applications, apis, policies, assignments, decisions);
    ports.demoData = new DemoDataService(ports.applications, ports.apis, ports.policies, ports.assignments,
      ports.evaluation);

    // one engine for all driving adapters
    engine = authorizationEngine(ports, config.maxPageSize);
  }

  /// Startup seeding (server): the base policies of the seed application and,
  /// if configured, the demo landscape.
  void bootstrap() {
    auto system = UserId("system");
    if (config.seedDemoData && ports.demoData.isEmpty(TenantId(config.defaultTenant)))
      ports.demoData.seed(TenantId(config.defaultTenant), system);
    if (!config.seedBasePolicies)
      return;
    auto tenant = TenantId(config.seedTenantId);
    ManagedApplication app;
    foreach (a; ports.applications.listApplications(tenant))
      if (a.name == config.seedAppName)
        app = a;
    if (app.isNull) {
      CreateApplicationRequest r;
      r.tenantId = tenant;
      r.actor = system;
      r.name = config.seedAppName;
      r.organizationId = config.seedOrganizationId;
      r.description = "Seeded application carrying the AMS base policies";
      app = ports.applications.createApplication(r);
    }
    ports.policies.seedBasePolicies(tenant, app.id, system);
  }
}
