/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.xyz.infrastructure.container;

import uim.platform.xyz.infrastructure.config;

// Repositories
import uim.platform.xyz.infrastructure.persistence.memory.destination_repo;
import uim.platform.xyz.infrastructure.persistence.memory.certificate_repo;
import uim.platform.xyz.infrastructure.persistence.memory.fragment_repo;

// Use Cases
import application.usecases.manage_destinations;
import application.usecases.manage_certificates;
import application.usecases.manage_fragments;
import application.usecases.find_destination;

// Controllers
import uim.platform.xyz.presentation.http.destination;
import uim.platform.xyz.presentation.http.certificate;
import uim.platform.xyz.presentation.http.fragment;
import uim.platform.xyz.presentation.http.find;
import uim.platform.xyz.presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container {
    // Repositories (driven adapters)
    InMemoryDestinationRepository destRepo;
    InMemoryCertificateRepository certRepo;
    InMemoryFragmentRepository fragRepo;

    // Use cases (application layer)
    ManageDestinationsUseCase manageDestinations;
    ManageCertificatesUseCase manageCertificates;
    ManageFragmentsUseCase manageFragments;
    FindDestinationUseCase findDestination;

    // Controllers (driving adapters)
    DestinationController destinationController;
    CertificateController certificateController;
    FragmentController fragmentController;
    FindController findController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.destRepo = new MemoryDestinationRepository();
    c.certRepo = new MemoryCertificateRepository();
    c.fragRepo = new MemoryFragmentRepository();

    // Application use cases
    c.manageDestinations = new ManageDestinationsUseCase(c.destRepo);
    c.manageCertificates = new ManageCertificatesUseCase(c.certRepo);
    c.manageFragments = new ManageFragmentsUseCase(c.fragRepo);
    c.findDestination = new FindDestinationUseCase(c.destRepo, c.fragRepo, c.certRepo);

    // Presentation controllers
    c.destinationController = new DestinationController(c.manageDestinations);
    c.certificateController = new CertificateController(c.manageCertificates);
    c.fragmentController = new FragmentController(c.manageFragments);
    c.findController = new FindController(c.findDestination);
    c.healthController = new HealthController("destination");

    return c;
}
