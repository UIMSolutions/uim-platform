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

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto platformRepo = new PlatformRepository();
    auto serviceBrokerRepo = new ServiceBrokerRepository();
    auto serviceOfferingRepo = new ServiceOfferingRepository();
    auto servicePlanRepo = new ServicePlanRepository();
    auto serviceInstanceRepo = new ServiceInstanceRepository();
    auto serviceBindingRepo = new ServiceBindingRepository();
    auto operationRepo = new OperationRepository();
    auto labelRepo = new LabelRepository();

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
