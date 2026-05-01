/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.application.usecases.manage.fragments;

// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.destination_fragment;
// import uim.platform.destination.domain.ports.repositories.fragments;
// import uim.platform.destination.domain.types;

// // import std.conv : to;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Application service for destination fragment CRUD operations.
class ManageFragmentsUseCase { // TODO: UIMUseCase {
  private FragmentRepository repo;

  this(FragmentRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateFragmentRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Fragment name is required");

    auto existing = repo.findByName(req.tenantId, req.subaccountId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Fragment '" ~ req.name ~ "' already exists");

    DestinationFragment f;
    f.id = randomUUID();
    f.tenantId = req.tenantId;
    f.subaccountId = req.subaccountId;
    f.name = req.name;
    f.description = req.description;
    f.level = parseLevel(req.level);
    f.url = req.url;
    f.authenticationType = req.authenticationType;
    f.proxyType = req.proxyType;
    f.user = req.user;
    f.password = req.password;
    f.clientId = req.clientId;
    f.clientSecret = req.clientSecret;
    f.tokenServiceUrl = req.tokenServiceUrl;
    f.locationId = req.locationId;
    f.keystoreId = req.keystoreId;
    f.truststoreId = req.truststoreId;
    f.properties = req.properties;
    f.createdBy = req.createdBy;
    f.createdAt = clockSeconds();
    f.updatedAt = f.createdAt;

    repo.save(f);
    return CommandResult(true, f.id.toString, "");
  }

  CommandResult updateFragment(FragmentId id, UpdateFragmentRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Fragment not found");

    auto fragment = repo.findById(id);
    if (req.description.length > 0)
      fragment.description = req.description;
    if (req.url.length > 0)
      fragment.url = req.url;
    if (req.authenticationType.length > 0)
      fragment.authenticationType = req.authenticationType;
    if (req.proxyType.length > 0)
      fragment.proxyType = req.proxyType;
    if (req.user.length > 0)
      fragment.user = req.user;
    if (req.password.length > 0)
      fragment.password = req.password;
    if (req.clientId.length > 0)
      fragment.clientId = req.clientId;
    if (req.clientSecret.length > 0)
      fragment.clientSecret = req.clientSecret;
    if (req.tokenServiceUrl.length > 0)
      fragment.tokenServiceUrl = req.tokenServiceUrl;
    if (req.locationId.length > 0)
      fragment.locationId = req.locationId;
    if (req.keystoreId.length > 0)
      fragment.keystoreId = req.keystoreId;
    if (req.truststoreId.length > 0)
      fragment.truststoreId = req.truststoreId;
    if (req.properties.length > 0)
      fragment.properties = req.properties;
    fragment.updatedAt = clockSeconds();

    repo.update(fragment);
    return CommandResult(true, fragment.id.toString, "");
  }

  DestinationFragment getFragment(FragmentId id) {
    return repo.findById(id);
  }

  DestinationFragment[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return repo.findBySubaccount(tenantId, subaccountId);
  }

  CommandResult removeFragment(FragmentId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Fragment not found");

    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }

  private static DestinationLevel parseLevel(string s) {
    switch (s) {
    case "serviceInstance":
      return DestinationLevel.serviceInstance;
    default:
      return DestinationLevel.subaccount;
    }
  }
}
