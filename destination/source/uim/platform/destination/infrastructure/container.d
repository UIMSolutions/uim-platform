/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.infrastructure.container;

import uim.platform.destination.infrastructure.config;

// Repositories
import uim.platform.destination.infrastructure.persistence.memory.destination;
import uim.platform.destination.infrastructure.persistence.memory.certificate;
import uim.platform.destination.infrastructure.persistence.memory.fragment;

// Use Cases
import uim.platform.destination.application.usecases.manage.destinations;
import uim.platform.destination.application.usecases.manage.certificates;
import uim.platform.destination.application.usecases.manage.fragments;
import uim.platform.destination.application.usecases.find_destination;

// Controllers
import uim.platform.destination.presentation.http.destination;
import uim.platform.destination.presentation.http.certificate;
import uim.platform.destination.presentation.http.fragment;
import uim.platform.destination.presentation.http.find;
import uim.platform.destination.presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemoryDestinationRepository destRepo;
  MemoryCertificateRepository certRepo;
  MemoryFragmentRepository fragRepo;

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
