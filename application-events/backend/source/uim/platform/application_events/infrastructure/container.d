/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Composition root shared by the server, the CLI and the GUI.
module uim.platform.application_events.infrastructure.container;

import uim.platform.application_events;
import uim.platform.application_events.presentation.odata.engine : eventHubEngine;
import uim.platform.service.presentation.odata.engine : ODataEngine;

mixin(ShowModule!());

@safe:

class AehContainer {
  AehConfig config;
  IDocumentStore store;
  IAehUnitOfWork unitOfWork;
  IClock clock;
  LoggingAuditTrail audit;
  AehRepositories repositories;
  AehPorts ports;
  IDeliveryGateway gateway;
  WorkerMetrics metrics;
  ODataEngine engine; /// drives OData, REST, CLI and GUI
  SecuritySetup security; /// authentication mode, verifier and token issuer

  /// storage / clock / delivery gateway may be injected (tests); defaults follow the configuration.
  this(AehConfig config, StorageSetup storage = StorageSetup.init, IClock clock = null, IDeliveryGateway gateway = null) {
    this.config = config;
    if (storage.store is null)
      storage = createStorage(config.storage, config.dataFile);
    store = storage.store;
    unitOfWork = storage.unitOfWork !is null ? storage.unitOfWork : new ImmediateAehUnitOfWork;
    this.clock = clock !is null ? clock : new SystemClock;
    audit = new LoggingAuditTrail;
    metrics = new WorkerMetrics;

    // driven adapters
    repositories = createRepositories(store);
    this.gateway = gateway !is null ? gateway : config.deliveryMode == "http"
      ? cast(IDeliveryGateway) new HttpDeliveryGateway(config.deliveryTimeoutSeconds, config.serviceName ~ "/"
          ~ config.serviceVersion) : cast(IDeliveryGateway) new SimulatedDeliveryGateway;

    // security (token verification and issuing, password hashing)
    security = configureSecurity(config);
    auto hasher = new Pbkdf2PasswordHasher(config.passwordIterations);

    // application
    auto p = config.policy;
    T wire(T, Args...)(Args extra) {
      return new T(repositories, this.clock, audit, unitOfWork, p, extra);
    }

    ports.formations = wire!ManageFormationsUseCase();
    ports.systems = wire!ManageSystemsUseCase();
    ports.topics = wire!ManageTopicsUseCase();
    ports.channels = wire!ManageChannelsUseCase();
    ports.subscriptions = wire!ManageSubscriptionsUseCase();
    ports.filters = wire!ManageFiltersUseCase();
    auto delivery = wire!DeliveryUseCase(this.gateway);
    ports.delivery = delivery;
    ports.deadLetters = delivery;
    ports.publishing = wire!PublishEventsUseCase(delivery);
    ports.statistics = new AehStatisticsService(repositories, this.clock);
    auto access = wire!AccessUseCase(cast(IPasswordHasher) hasher, security.issuer);
    ports.authentication = access;
    ports.users = access;

    // one engine for all management adapters; the HTTP server switches on
    // scope enforcement (CLI and GUI are trusted local adapters)
    engine = eventHubEngine(ports, this.clock, config.maxPageSize);
  }
}
