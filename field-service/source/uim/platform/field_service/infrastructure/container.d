/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.container;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Container {
    ManageServiceCallsUseCase manageServiceCallsUseCase;
    ManageActivitiesUseCase manageActivitiesUseCase;
    ManageAssignmentsUseCase manageAssignmentsUseCase;
    ManageEquipmentUseCase manageEquipmentUseCase;
    ManageTechniciansUseCase manageTechniciansUseCase;
    ManageCustomersUseCase manageCustomersUseCase;
    ManageSkillsUseCase manageSkillsUseCase;
    ManageSmartformsUseCase manageSmartformsUseCase;

    ServiceCallController serviceCallController;
    ActivityController activityController;
    AssignmentController assignmentController;
    EquipmentController equipmentController;
    TechnicianController technicianController;
    CustomerController customerController;
    SkillController skillController;
    SmartformController smartformController;
    HealthController healthController;
}

Container buildContainer(SrvConfig config) {
    Container c;

    // Repositories
    auto serviceCallRepo = new MemoryServiceCallRepository();
    auto activityRepo = new MemoryActivityRepository();
    auto assignmentRepo = new MemoryAssignmentRepository();
    auto equipmentRepo = new MemoryEquipmentRepository();
    auto technicianRepo = new MemoryTechnicianRepository();
    auto customerRepo = new MemoryCustomerRepository();
    auto skillRepo = new MemorySkillRepository();
    auto smartformRepo = new MemorySmartformRepository();

    // Use Cases
    c.manageServiceCallsUseCase = new ManageServiceCallsUseCase(serviceCallRepo);
    c.manageActivitiesUseCase = new ManageActivitiesUseCase(activityRepo);
    c.manageAssignmentsUseCase = new ManageAssignmentsUseCase(assignmentRepo);
    c.manageEquipmentUseCase = new ManageEquipmentUseCase(equipmentRepo);
    c.manageTechniciansUseCase = new ManageTechniciansUseCase(technicianRepo);
    c.manageCustomersUseCase = new ManageCustomersUseCase(customerRepo);
    c.manageSkillsUseCase = new ManageSkillsUseCase(skillRepo);
    c.manageSmartformsUseCase = new ManageSmartformsUseCase(smartformRepo);

    // Controllers
    c.serviceCallController = new ServiceCallController(c.manageServiceCallsUseCase);
    c.activityController = new ActivityController(c.manageActivitiesUseCase);
    c.assignmentController = new AssignmentController(c.manageAssignmentsUseCase);
    c.equipmentController = new EquipmentController(c.manageEquipmentUseCase);
    c.technicianController = new TechnicianController(c.manageTechniciansUseCase);
    c.customerController = new CustomerController(c.manageCustomersUseCase);
    c.skillController = new SkillController(c.manageSkillsUseCase);
    c.smartformController = new SmartformController(c.manageSmartformsUseCase);
    c.healthController = new HealthController();

    return c;
}
