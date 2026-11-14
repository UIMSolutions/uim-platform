/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.destinations;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Interactor: destinations. Names are unique per tenant; URL, authentication
/// and certificate references are validated on every change.
class ManageDestinationsUseCase
  : ResourceUseCase!(Destination, DestinationId, CreateDestinationRequest, UpdateDestinationRequest),
  IManageDestinationsUseCase {

  protected DestinationChecker checker;

  this(ConnectivityRepositories repos, EventRecorder events, DestinationChecker checker) {
    super(repos, repos.destinations, events, "Destination", "connectivity.destination");
    this.checker = checker;
  }

  override protected Destination build(CreateDestinationRequest r) {
    auto d = Destination(r.tenantId);
    assignMatching(d, r.spec);
    d.name = d.name.strip;
    check(d);
    ensureUnique(repos.destinations.findByName(r.tenantId, d.name), d, "this tenant");
    return d;
  }

  /// The name is the key used by applications and cannot change.
  override protected void apply(ref Destination d, DestinationSpec spec) {
    assignMatching(d, spec, ["name"]);
    check(d);
    d.status = DestinationStatus.unchecked;
    d.statusMessage = "Configuration changed";
  }

  protected void check(ref Destination d) {
    validateDestinationName(d.name);
    d.url = d.url.strip;
    validateDestinationUrl(d.destinationType, d.url);
    validateAuthentication(d);
    if (!d.certificateId.isEmpty)
      d.certificateId = resolveCertificate(d.tenantId, d.certificateId);
    if (d.proxyType == ProxyType.onPremise)
      validateLocationId(d.cloudConnectorLocationId);
    else
      d.cloudConnectorLocationId = "";
    foreach (h; d.additionalHeaders)
      validate(h.key.strip.length > 0 && !h.key.canFind(' '), "Header names must not be empty or contain blanks");
  }

  /// A certificate given by id or by name.
  protected CertificateId resolveCertificate(TenantId tenantId, CertificateId idOrName) {
    if (!repos.certificates.findById(tenantId, idOrName).isNull)
      return idOrName;
    auto byName = repos.certificates.findByName(tenantId, idOrName.value);
    if (byName.isNull)
      throw new ConnectivityNotFoundException("Certificate '" ~ idOrName.value ~ "' not found");
    return byName.id;
  }

  Destination findByName(TenantId tenantId, string name) {
    return repos.destinations.findByName(tenantId, name);
  }

  UsecaseResult check(TenantId tenantId, DestinationId id, UserId actor) {
    return guarded(() {
      auto d = require(tenantId, id);
      checker.run(d, nowStdTime(), true, actor);
      d.update(actor);
      repo.update(d);
      publish(d, "checked");
      return succeeded(d.id.value, "Destination '" ~ d.name ~ "' is " ~ enumText(d.status) ~ ": " ~ d.statusMessage);
    });
  }
}
