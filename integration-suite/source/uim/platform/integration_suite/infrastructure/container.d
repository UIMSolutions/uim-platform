module uim.platform.integration_suite.infrastructure.container;
import uim.platform.integration_suite;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires all architecture layers together.
struct Container {
  // --- Repositories (driven adapters / infrastructure) ---
  IIntegrationPackageRepository packageRepo;
  IIntegrationFlowRepository    flowRepo;
  IApiProxyRepository           apiProxyRepo;
  IApiProductRepository         apiProductRepo;
  IMessageQueueRepository       queueRepo;
  ITopicSubscriptionRepository  subscriptionRepo;
  ITradingPartnerRepository     partnerRepo;
  IMessageMappingRepository     mappingRepo;
  IIntegrationUserRepository    userRepo;

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
  c.packageRepo      = new IntegrationPackageRepository();
  c.flowRepo         = new IntegrationFlowRepository();
  c.apiProxyRepo     = new ApiProxyRepository();
  c.apiProductRepo   = new ApiProductRepository();
  c.queueRepo        = new MessageQueueRepository();
  c.subscriptionRepo = new TopicSubscriptionRepository();
  c.partnerRepo      = new TradingPartnerRepository();
  c.mappingRepo      = new MessageMappingRepository();
  c.userRepo         = new IntegrationUserRepository();

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
