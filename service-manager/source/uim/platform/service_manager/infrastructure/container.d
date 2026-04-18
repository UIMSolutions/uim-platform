module uim.platform.service_manager.infrastructure.container;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

struct Container {
    ManagePlatformsUseCase managePlatformsUseCase;
    ManageServiceBrokersUseCase manageServiceBrokersUseCase;
    ManageServiceOfferingsUseCase manageServiceOfferingsUseCase;
    ManageServicePlansUseCase manageServicePlansUseCase;
    ManageServiceInstancesUseCase manageServiceInstancesUseCase;
    ManageServiceBindingsUseCase manageServiceBindingsUseCase;
    ManageOperationsUseCase manageOperationsUseCase;
    ManageLabelsUseCase manageLabelsUseCase;

    PlatformController platformController;
    ServiceBrokerController serviceBrokerController;
    ServiceOfferingController serviceOfferingController;
    ServicePlanController servicePlanController;
    ServiceInstanceController serviceInstanceController;
    ServiceBindingController serviceBindingController;
    OperationController operationController;
    LabelController labelController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Repositories
    auto platformRepo = new MemoryPlatformRepository();
    auto serviceBrokerRepo = new MemoryServiceBrokerRepository();
    auto serviceOfferingRepo = new MemoryServiceOfferingRepository();
    auto servicePlanRepo = new MemoryServicePlanRepository();
    auto serviceInstanceRepo = new MemoryServiceInstanceRepository();
    auto serviceBindingRepo = new MemoryServiceBindingRepository();
    auto operationRepo = new MemoryOperationRepository();
    auto labelRepo = new MemoryLabelRepository();

    // Use Cases
    c.managePlatformsUseCase = new ManagePlatformsUseCase(platformRepo);
    c.manageServiceBrokersUseCase = new ManageServiceBrokersUseCase(serviceBrokerRepo);
    c.manageServiceOfferingsUseCase = new ManageServiceOfferingsUseCase(serviceOfferingRepo);
    c.manageServicePlansUseCase = new ManageServicePlansUseCase(servicePlanRepo);
    c.manageServiceInstancesUseCase = new ManageServiceInstancesUseCase(serviceInstanceRepo);
    c.manageServiceBindingsUseCase = new ManageServiceBindingsUseCase(serviceBindingRepo);
    c.manageOperationsUseCase = new ManageOperationsUseCase(operationRepo);
    c.manageLabelsUseCase = new ManageLabelsUseCase(labelRepo);

    // Controllers
    c.platformController = new PlatformController(c.managePlatformsUseCase);
    c.serviceBrokerController = new ServiceBrokerController(c.manageServiceBrokersUseCase);
    c.serviceOfferingController = new ServiceOfferingController(c.manageServiceOfferingsUseCase);
    c.servicePlanController = new ServicePlanController(c.manageServicePlansUseCase);
    c.serviceInstanceController = new ServiceInstanceController(c.manageServiceInstancesUseCase);
    c.serviceBindingController = new ServiceBindingController(c.manageServiceBindingsUseCase);
    c.operationController = new OperationController(c.manageOperationsUseCase);
    c.labelController = new LabelController(c.manageLabelsUseCase);
    c.healthController = new HealthController();

    return c;
}
