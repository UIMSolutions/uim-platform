/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.infrastructure.container;

// import uim.platform.abap_environment.infrastructure.config;

// // Repositories
// import uim.platform.abap_environment.infrastructure.persistence.memory.system_instances;
// import uim.platform.abap_environment.infrastructure.persistence.memory.software_components;
// import uim.platform.abap_environment.infrastructure.persistence.memory.communication_arrangements;
// import uim.platform.abap_environment.infrastructure.persistence.memory.service_bindings;
// import uim.platform.abap_environment.infrastructure.persistence.memory.business_users;
// import uim.platform.abap_environment.infrastructure.persistence.memory.business_roles;
// import uim.platform.abap_environment.infrastructure.persistence.memory.transport_requests;
// import uim.platform.abap_environment.infrastructure.persistence.memory.application_jobs;

// // Use Cases
// import uim.platform.abap_environment.application.usecases.manage.system_instances;
// import uim.platform.abap_environment.application.usecases.manage.software_components;
// import uim.platform.abap_environment.application.usecases.manage.communication_arrangements;
// import uim.platform.abap_environment.application.usecases.manage.service_bindings;
// import uim.platform.abap_environment.application.usecases.manage.business_users;
// import uim.platform.abap_environment.application.usecases.manage.business_roles;
// import uim.platform.abap_environment.application.usecases.manage.transport_requests;
// import uim.platform.abap_environment.application.usecases.manage.application_jobs;

// // Controllers
// import uim.platform.abap_environment.presentation.http.system_instance;
// import uim.platform.abap_environment.presentation.http.software_component;
// import uim.platform.abap_environment.presentation.http.communication_arrangement;
// import uim.platform.abap_environment.presentation.http.service_binding;
// import uim.platform.abap_environment.presentation.http.business_user;
// import uim.platform.abap_environment.presentation.http.business_role;
// import uim.platform.abap_environment.presentation.http.transport_request;
// import uim.platform.abap_environment.presentation.http.application_job;
// import uim.platform.abap_environment.presentation.http.health;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Dependency injection container - wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemorySystemInstanceRepository systemInstanceRepo;
  MemorySoftwareComponentRepository softwareComponentRepo;
  MemoryCommunicationArrangementRepository communicationArrangementRepo;
  MemoryServiceBindingRepository serviceBindingRepo;
  MemoryBusinessUserRepository businessUserRepo;
  MemoryBusinessRoleRepository businessRoleRepo;
  MemoryTransportRequestRepository transportRequestRepo;
  MemoryApplicationJobRepository applicationJobRepo;

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
Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure adapters
  c.systemInstanceRepo = new MemorySystemInstanceRepository();
  c.softwareComponentRepo = new MemorySoftwareComponentRepository();
  c.communicationArrangementRepo = new MemoryCommunicationArrangementRepository();
  c.serviceBindingRepo = new MemoryServiceBindingRepository();
  c.businessUserRepo = new MemoryBusinessUserRepository();
  c.businessRoleRepo = new MemoryBusinessRoleRepository();
  c.transportRequestRepo = new MemoryTransportRequestRepository();
  c.applicationJobRepo = new MemoryApplicationJobRepository();

  // Application use cases
  c.manageSystemInstances = new ManageSystemInstancesUseCase(c.systemInstanceRepo);
  c.manageSoftwareComponents = new ManageSoftwareComponentsUseCase(
      c.softwareComponentRepo, c.systemInstanceRepo);
  c.manageCommunicationArrangements = new ManageCommunicationArrangementsUseCase(
      c.communicationArrangementRepo);
  c.manageServiceBindings = new ManageServiceBindingsUseCase(c.serviceBindingRepo);
  c.manageBusinessUsers = new ManageBusinessUsersUseCase(c.businessUserRepo, c.businessRoleRepo);
  c.manageBusinessRoles = new ManageBusinessRolesUseCase(c.businessRoleRepo);
  c.manageTransportRequests = new ManageTransportRequestsUseCase(c.transportRequestRepo);
  c.manageApplicationJobs = new ManageApplicationJobsUseCase(c.applicationJobRepo);

  // Presentation controllers
  c.systemInstanceController = new SystemInstanceController(c.manageSystemInstances);
  c.softwareComponentController = new SoftwareComponentController(c.manageSoftwareComponents);
  c.communicationArrangementController = new CommunicationArrangementController(
      c.manageCommunicationArrangements);
  c.serviceBindingController = new ServiceBindingController(c.manageServiceBindings);
  c.businessUserController = new BusinessUserController(c.manageBusinessUsers);
  c.businessRoleController = new BusinessRoleController(c.manageBusinessRoles);
  c.transportRequestController = new TransportRequestController(c.manageTransportRequests);
  c.applicationJobController = new ApplicationJobController(c.manageApplicationJobs);
  c.healthController = new HealthController("abap-environment");

  return c;
}
