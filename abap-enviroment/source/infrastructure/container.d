module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_system_instance_repo;
import infrastructure.persistence.in_memory_software_component_repo;
import infrastructure.persistence.in_memory_communication_arrangement_repo;
import infrastructure.persistence.in_memory_service_binding_repo;
import infrastructure.persistence.in_memory_business_user_repo;
import infrastructure.persistence.in_memory_business_role_repo;
import infrastructure.persistence.in_memory_transport_request_repo;
import infrastructure.persistence.in_memory_application_job_repo;

// Use Cases
import application.use_cases.manage_system_instances;
import application.use_cases.manage_software_components;
import application.use_cases.manage_communication_arrangements;
import application.use_cases.manage_service_bindings;
import application.use_cases.manage_business_users;
import application.use_cases.manage_business_roles;
import application.use_cases.manage_transport_requests;
import application.use_cases.manage_application_jobs;

// Controllers
import presentation.http.system_instance_controller;
import presentation.http.software_component_controller;
import presentation.http.communication_arrangement_controller;
import presentation.http.service_binding_controller;
import presentation.http.business_user_controller;
import presentation.http.business_role_controller;
import presentation.http.transport_request_controller;
import presentation.http.application_job_controller;
import presentation.http.health_controller;

/// Dependency injection container - wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemorySystemInstanceRepository systemInstanceRepo;
    InMemorySoftwareComponentRepository softwareComponentRepo;
    InMemoryCommunicationArrangementRepository communicationArrangementRepo;
    InMemoryServiceBindingRepository serviceBindingRepo;
    InMemoryBusinessUserRepository businessUserRepo;
    InMemoryBusinessRoleRepository businessRoleRepo;
    InMemoryTransportRequestRepository transportRequestRepo;
    InMemoryApplicationJobRepository applicationJobRepo;

    // Use cases (application layer)
    ManageSystemInstancesUseCase manageSystemInstances;
    ManageSoftwareComponentsUseCase manageSoftwareComponents;
    ManageCommunicationArrangementsUseCase manageCommunicationArrangements;
    ManageServiceBindingsUseCase manageServiceBindings;
    ManageBusinessUsersUseCase manageBusinessUsers;
    ManageBusinessRolesUseCase manageBusinessRoles;
    ManageTransportRequestsUseCase manageTransportRequests;
    ManageApplicationJobsUseCase manageApplicationJobs;

    // Controllers (driving adapters)
    SystemInstanceController systemInstanceController;
    SoftwareComponentController softwareComponentController;
    CommunicationArrangementController communicationArrangementController;
    ServiceBindingController serviceBindingController;
    BusinessUserController businessUserController;
    BusinessRoleController businessRoleController;
    TransportRequestController transportRequestController;
    ApplicationJobController applicationJobController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.systemInstanceRepo = new InMemorySystemInstanceRepository();
    c.softwareComponentRepo = new InMemorySoftwareComponentRepository();
    c.communicationArrangementRepo = new InMemoryCommunicationArrangementRepository();
    c.serviceBindingRepo = new InMemoryServiceBindingRepository();
    c.businessUserRepo = new InMemoryBusinessUserRepository();
    c.businessRoleRepo = new InMemoryBusinessRoleRepository();
    c.transportRequestRepo = new InMemoryTransportRequestRepository();
    c.applicationJobRepo = new InMemoryApplicationJobRepository();

    // Application use cases
    c.manageSystemInstances = new ManageSystemInstancesUseCase(c.systemInstanceRepo);
    c.manageSoftwareComponents = new ManageSoftwareComponentsUseCase(c.softwareComponentRepo, c.systemInstanceRepo);
    c.manageCommunicationArrangements = new ManageCommunicationArrangementsUseCase(c.communicationArrangementRepo);
    c.manageServiceBindings = new ManageServiceBindingsUseCase(c.serviceBindingRepo);
    c.manageBusinessUsers = new ManageBusinessUsersUseCase(c.businessUserRepo, c.businessRoleRepo);
    c.manageBusinessRoles = new ManageBusinessRolesUseCase(c.businessRoleRepo);
    c.manageTransportRequests = new ManageTransportRequestsUseCase(c.transportRequestRepo);
    c.manageApplicationJobs = new ManageApplicationJobsUseCase(c.applicationJobRepo);

    // Presentation controllers
    c.systemInstanceController = new SystemInstanceController(c.manageSystemInstances);
    c.softwareComponentController = new SoftwareComponentController(c.manageSoftwareComponents);
    c.communicationArrangementController = new CommunicationArrangementController(c.manageCommunicationArrangements);
    c.serviceBindingController = new ServiceBindingController(c.manageServiceBindings);
    c.businessUserController = new BusinessUserController(c.manageBusinessUsers);
    c.businessRoleController = new BusinessRoleController(c.manageBusinessRoles);
    c.transportRequestController = new TransportRequestController(c.manageTransportRequests);
    c.applicationJobController = new ApplicationJobController(c.manageApplicationJobs);
    c.healthController = new HealthController();

    return c;
}
