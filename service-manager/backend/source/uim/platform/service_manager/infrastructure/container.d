/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.service_manager.infrastructure.container;

import uim.platform.service_manager;
import uim.platform.service_manager.presentation.odata.engine : serviceManagerEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class ServiceManagerContainer {
  ServiceManagerConfig config;
  IDocumentStore store;
  ServiceManagerPorts ports;
  OperationTracker tracker;
  ODataEngine engine; /// drives OData, REST, CLI and GUI

  /// gateway / store may be injected (tests); defaults follow the configuration.
  this(ServiceManagerConfig config, IBrokerCatalogGateway gateway = null, IDocumentStore store = null) {
    this.config = config;
    this.store = store !is null ? store : createDocumentStore(config.storage, config.dataFile);
    if (gateway is null)
      gateway = new OsbCatalogClient(config.brokerApiVersion, config.brokerTimeoutSeconds);

    // driven adapters
    auto platforms = new PlatformRepository(this.store);
    auto brokers = new ServiceBrokerRepository(this.store);
    auto offerings = new ServiceOfferingRepository(this.store);
    auto plans = new ServicePlanRepository(this.store);
    auto instances = new ServiceInstanceRepository(this.store);
    auto bindings = new ServiceBindingRepository(this.store);
    auto operations = new OperationRepository(this.store);
    auto labels = new LabelRepository(this.store);

    // application
    tracker = new OperationTracker(operations, config.syncProvisioning ? ProvisioningMode.synchronous
        : ProvisioningMode.asynchronous);
    auto directory = new ResourceDirectory(platforms, brokers, offerings, plans, instances, bindings);

    ports.platforms = new ManagePlatformsUseCase(platforms, instances, labels);
    ports.brokers = new ManageServiceBrokersUseCase(brokers, offerings, plans, instances, labels);
    ports.offerings = new ManageServiceOfferingsUseCase(offerings, brokers, plans, labels);
    ports.plans = new ManageServicePlansUseCase(plans, offerings, instances, labels);
    ports.instances = new ManageServiceInstancesUseCase(instances, plans, offerings, brokers, platforms, bindings, labels, tracker);
    ports.bindings = new ManageServiceBindingsUseCase(bindings, instances, plans, offerings, brokers, labels, tracker);
    ports.operations = new ManageOperationsUseCase(operations, instances, bindings, labels);
    ports.labels = new ManageLabelsUseCase(labels, directory);
    ports.catalogSync = new SyncBrokerCatalogUseCase(brokers, offerings, plans, gateway);
    ports.statistics = new StatisticsService(platforms, brokers, offerings, plans, instances, bindings, operations, labels);

    // one engine for all driving adapters
    engine = serviceManagerEngine(ports, config.maxPageSize);
  }
}
