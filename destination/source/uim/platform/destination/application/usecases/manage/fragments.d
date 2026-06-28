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
// 
import uim.platform.destination;

// mixin(ShowModule!());

@safe:
/// Application service for destination fragment CRUD operations.
class ManageFragmentsUseCase { // TODO: UIMUseCase {
  private FragmentRepository repo;

  this(FragmentRepository repo) {
    this.repo = repo;
  }

  CommandResult createFragment(CreateFragmentRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Fragment name is required");

    auto existing = repo.findByName(req.tenantId, req.subaccountId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Fragment '" ~ req.name ~ "' already exists");

    DestinationFragment f;
    f.initEntity(req.tenantId, req.createdBy);

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

    repo.save(f);
    return CommandResult(true, f.id.value, "");
  }

  CommandResult updateFragment(UpdateFragmentRequest req) {
    auto fragment = repo.findById(req.tenantId, req.fragmentId);
    if (fragment.isNull)
      return CommandResult(false, "", "Fragment not found");

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
    return CommandResult(true, fragment.id.value, "");
  }

  /// Checks if a fragment with the given ID exists for the tenant.
  bool hasFragment(TenantId tenantId, DestinationFragmentId id) {
    return repo.existsById(tenantId, id);
  }

  /// Retrieves a fragment by its ID.
  DestinationFragment getFragment(TenantId tenantId, DestinationFragmentId id) {
    return repo.find(tenantId, id);
  }

  /// Lists all fragments for a given tenant and subaccount.
  DestinationFragment[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return repo.findBySubaccount(tenantId, subaccountId);
  }

  /// Lists all fragments for a given tenant and level.
  DestinationFragment[] listByLevel(TenantId tenantId, DestinationLevel level) {
    return repo.findByLevel(tenantId, level);
  }

  /// Deletes a fragment by its ID.
  CommandResult deleteFragment(TenantId tenantId, DestinationFragmentId id) {
    auto fragment = repo.find(tenantId, id);
    if (fragment.isNull)
      return CommandResult(false, "", "Fragment not found");

    repo.remove(fragment);
    return CommandResult(true, fragment.id.value, "");
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
