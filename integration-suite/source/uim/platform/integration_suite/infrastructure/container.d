module uim.platform.integration_suite.infrastructure.container;
import uim.platform.integration_suite;

// mixin(ShowModule!());

@safe:

/// Dependency injection container — wires all architecture layers together.
struct Container {
  // --- Repositories (driven adapters / infrastructure) ---
  MemoryIntegrationPackageRepository packageRepo;
  MemoryIntegrationFlowRepository    flowRepo;
  MemoryApiProxyRepository           apiProxyRepo;
  MemoryApiProductRepository         apiProductRepo;
  MemoryMessageQueueRepository       queueRepo;
  MemoryTopicSubscriptionRepository  subscriptionRepo;
  MemoryTradingPartnerRepository     partnerRepo;
  MemoryMessageMappingRepository     mappingRepo;
  MemoryIntegrationUserRepository    userRepo;

  // --- Use cases (application layer) ---
  ManageIntegrationPackagesUseCase managePackages;
  ManageIntegrationFlowsUseCase    manageFlows;
  ManageApiProxiesUseCase          manageApiProxies;
  ManageApiProductsUseCase         manageApiProducts;
  ManageMessageQueuesUseCase       manageQueues;
  ManageTopicSubscriptionsUseCase  manageSubscriptions;
  ManageTradingPartnersUseCase     managePartners;
  ManageMessageMappingsUseCase     manageMappings;

  // --- Controllers (driving adapters / presentation) ---
  IntegrationPackageController packageController;
  IntegrationFlowController    flowController;
  ApiProxyController           apiProxyController;
  ApiProductController         apiProductController;
  MessageQueueController       queueController;
  TopicSubscriptionController  subscriptionController;
  TradingPartnerController     partnerController;
  MessageMappingController     mappingController;
  IntegrationUserController    userController;
  HealthController             healthController;
}

/// Build the full dependency graph.
Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure adapters
  c.packageRepo      = new MemoryIntegrationPackageRepository();
  c.flowRepo         = new MemoryIntegrationFlowRepository();
  c.apiProxyRepo     = new MemoryApiProxyRepository();
  c.apiProductRepo   = new MemoryApiProductRepository();
  c.queueRepo        = new MemoryMessageQueueRepository();
  c.subscriptionRepo = new MemoryTopicSubscriptionRepository();
  c.partnerRepo      = new MemoryTradingPartnerRepository();
  c.mappingRepo      = new MemoryMessageMappingRepository();
  c.userRepo         = new MemoryIntegrationUserRepository();

  // Application use cases
  c.managePackages      = new ManageIntegrationPackagesUseCase(c.packageRepo);
  c.manageFlows         = new ManageIntegrationFlowsUseCase(c.flowRepo);
  c.manageApiProxies    = new ManageApiProxiesUseCase(c.apiProxyRepo);
  c.manageApiProducts   = new ManageApiProductsUseCase(c.apiProductRepo);
  c.manageQueues        = new ManageMessageQueuesUseCase(c.queueRepo);
  c.manageSubscriptions = new ManageTopicSubscriptionsUseCase(c.subscriptionRepo);
  c.managePartners      = new ManageTradingPartnersUseCase(c.partnerRepo);
  c.manageMappings      = new ManageMessageMappingsUseCase(c.mappingRepo);

  // Presentation controllers
  c.packageController      = new IntegrationPackageController(c.managePackages);
  c.flowController         = new IntegrationFlowController(c.manageFlows);
  c.apiProxyController     = new ApiProxyController(c.manageApiProxies);
  c.apiProductController   = new ApiProductController(c.manageApiProducts);
  c.queueController        = new MessageQueueController(c.manageQueues);
  c.subscriptionController = new TopicSubscriptionController(c.manageSubscriptions);
  c.partnerController      = new TradingPartnerController(c.managePartners);
  c.mappingController      = new MessageMappingController(c.manageMappings);
  c.userController         = new IntegrationUserController(c.userRepo);
  c.healthController       = new HealthController("integration-suite");

  return c;
}
