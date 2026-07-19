/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.container;
import uim.platform.private_link;
mixin(ShowModule!());

@safe:
/// Dependency injection container — wires all layers of the Private Link Service.
struct Container {
  // ── Repositories (primary ports adapters) ─────────────────────────────────
  MemoryServiceInstanceRepository instanceRepo;
  MemoryPrivateEndpointRepository endpointRepo;
  MemoryServiceBindingRepository  bindingRepo;

  // ── Domain services ────────────────────────────────────────────────────────
  EndpointResolver endpointResolver;

  // ── Use cases (application layer) ─────────────────────────────────────────
  ManageServiceInstancesUseCase manageInstances;
  ManagePrivateEndpointsUseCase manageEndpoints;
  ManageServiceBindingsUseCase  manageBindings;

  // ── HTTP controllers (presentation layer) ─────────────────────────────────
  ServiceInstanceController instanceController;
  PrivateEndpointController endpointController;
  ServiceBindingController  bindingController;
  HealthController          healthController;
}

/// Build the full dependency graph in correct construction order.
Container buildContainer(SrvConfig config) {
  Container c;

  // 1. Repositories
  c.instanceRepo = new MemoryServiceInstanceRepository();
  c.endpointRepo = new MemoryPrivateEndpointRepository();
  c.bindingRepo  = new MemoryServiceBindingRepository();

  // 2. Domain services
  c.endpointResolver = new EndpointResolver(c.endpointRepo);

  // 3. Use cases
  c.manageInstances = new ManageServiceInstancesUseCase(c.instanceRepo, c.endpointRepo);
  c.manageEndpoints = new ManagePrivateEndpointsUseCase(c.endpointRepo, c.instanceRepo);
  c.manageBindings  = new ManageServiceBindingsUseCase(
      c.bindingRepo, c.instanceRepo, c.endpointRepo, c.endpointResolver);

  // 4. Controllers
  c.instanceController = new ServiceInstanceController(c.manageInstances);
  c.endpointController = new PrivateEndpointController(c.manageEndpoints);
  c.bindingController  = new ServiceBindingController(c.manageBindings);
  c.healthController   = new HealthController("private-link");

  return c;
}
