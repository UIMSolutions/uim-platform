/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module app;

import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

version (unittest) {
} else {
    void main() {
        auto config = loadConfig();
        auto container = buildContainer(config);

        auto router = new URLRouter();

        // Register all FHIR resource controllers
        container.patientController.registerRoutes(router);
        container.practitionerController.registerRoutes(router);
        container.observationController.registerRoutes(router);
        container.conditionController.registerRoutes(router);
        container.organizationController.registerRoutes(router);
        container.encounterController.registerRoutes(router);
        container.medicationController.registerRoutes(router);
        container.medicationRequestController.registerRoutes(router);

        // FHIR metadata + health
        container.capabilityController.registerRoutes(router);
        container.healthController.registerRoutes(router);

        auto settings = new HTTPServerSettings();
        settings.port = config.port;
        settings.bindAddresses = [config.host];

        auto listener = listenHTTP(settings, router);

        writefln("==========================================================================");
        writefln("  UIM Health Data Services for FHIR   (HL7 FHIR R4 / 4.0.1)");
        writefln("  Listening on %s:%d", config.host, config.port);
        writefln("  Storage backend: %s", config.storage);
        writefln("                                                                          ");
        writefln("  FHIR R4 Endpoints:                                                     ");
        writefln("    GET       /fhir/R4/metadata            (CapabilityStatement)         ");
        writefln("    CRUD      /fhir/R4/Patient             (FHIR Patient resource)       ");
        writefln("    CRUD      /fhir/R4/Practitioner        (FHIR Practitioner resource)  ");
        writefln("    CRUD      /fhir/R4/Observation         (FHIR Observation resource)   ");
        writefln("    CRUD      /fhir/R4/Condition           (FHIR Condition resource)     ");
        writefln("    CRUD      /fhir/R4/Organization        (FHIR Organization resource)  ");
        writefln("    CRUD      /fhir/R4/Encounter           (FHIR Encounter resource)     ");
        writefln("    CRUD      /fhir/R4/Medication          (FHIR Medication resource)    ");
        writefln("    CRUD      /fhir/R4/MedicationRequest   (FHIR MedicationRequest)      ");
        writefln("                                                                          ");
        writefln("  Search parameters (GET with ?subject=Patient/id, ?name=):              ");
        writefln("    Observation, Condition, Encounter, MedicationRequest                 ");
        writefln("                                                                          ");
        writefln("  Health:                                                                 ");
        writefln("    GET       /api/v1/health                                             ");
        writefln("==========================================================================");

        runApplication();
    }
}
