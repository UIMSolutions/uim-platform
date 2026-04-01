module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.memory.destination_repo;
import infrastructure.persistence.memory.certificate_repo;
import infrastructure.persistence.memory.fragment_repo;

// Use Cases
import application.usecases.manage_destinations;
import application.usecases.manage_certificates;
import application.usecases.manage_fragments;
import application.usecases.find_destination;

// Controllers
import presentation.http.destination_controller;
import presentation.http.certificate_controller;
import presentation.http.fragment_controller;
import presentation.http.find_controller;
import presentation.http.health_controller;

/// Dependency injection container - wires all layers together.
struct Container
{
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
Container buildContainer(AppConfig config)
{
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
    c.healthController = new HealthController();

    return c;
}
