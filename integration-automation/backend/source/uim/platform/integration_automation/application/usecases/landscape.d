/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// System landscape and destinations.
///
/// Rules: destination names are unique per tenant (case insensitive); a
/// destination may point to an existing system; systems and destinations
/// cannot be deleted while they are used (destinations, task templates,
/// open workflows).
module uim.platform.integration_automation.application.usecases.landscape;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class ManageSystemsUseCase : ResourceInteractor!(SystemConnection, SystemConnectionId, SystemInput), IManageSystems {
  protected IConnectivityProbe probe;

  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy,
    IConnectivityProbe probe) {
    super(repos, clock, events, unitOfWork, policy);
    this.probe = probe;
  }

  protected override IIaRepository!(SystemConnection, SystemConnectionId) store() {
    return repos.systems;
  }

  protected override string what() {
    return "System";
  }

  protected override string eventPrefix() {
    return "system";
  }

  protected override SystemInput toInput(const SystemConnection e) {
    SystemInput i;
    i.name = e.name;
    i.description = e.description;
    i.systemType = cast(string) e.systemType;
    i.host = e.host;
    i.port = e.port;
    i.protocol = e.protocol;
    i.client = e.client;
    i.sid = e.sid;
    i.environment = cast(string) e.environment;
    i.region = e.region;
    return i;
  }

  protected override void fromInput(TenantId t, ref SystemConnection e, SystemInput i, bool creating) {
    auto hostChanged = e.host != i.host.strip || e.port != i.port || e.protocol != i.protocol.strip.toLower;
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.systemType = parseDomainEnum!SystemType(i.systemType, "system type");
    e.host = i.host.strip;
    e.port = i.port;
    e.protocol = i.protocol.strip.toLower;
    e.client = i.client.strip;
    e.sid = i.sid.strip.toUpper;
    e.environment = parseDomainEnum!SystemEnvironment(i.environment, "environment");
    e.region = i.region.strip;
    if (!creating && hostChanged) // a new address has not been tested yet
      e.status = ConnectionStatus.inactive;
  }

  protected override void beforeRemove(TenantId t, const SystemConnection e, UserId actor) {
    requireUnused("System '" ~ e.id.value ~ "'", repos.destinations.countByReference(t, "systemId", e.id.value), "destinations");
    long open;
    foreach (wf; repos.workflows.findAll(t))
      if (wf.isOpen && (wf.sourceSystemId == e.id || wf.targetSystemId == e.id))
        open++;
    requireUnused("System '" ~ e.id.value ~ "'", open, "open workflows");
  }

  SystemConnection testConnection(TenantId t, SystemConnectionId id, UserId actor) {
    auto s = get(t, id);
    auto r = probe.probe(s.host, s.port, s.protocol);
    s.recordTest(r.reachable, r.message, now);
    stampUpdated(s, actor, now);
    store.save(s);
    record(t, WorkflowId.init, WorkflowTaskId.init, "system.tested", r.reachable ? ExecutionOutcome.success
        : ExecutionOutcome.failure, format("System '%s' (%s:%d): %s", s.name, s.host, s.port, r.message), actor.value,
        r.durationMs, "probe=" ~ probe.mode);
    return s;
  }
}

class ManageDestinationsUseCase : ResourceInteractor!(Destination, DestinationId, DestinationInput), IManageDestinations {
  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IIaRepository!(Destination, DestinationId) store() {
    return repos.destinations;
  }

  protected override string what() {
    return "Destination";
  }

  protected override string eventPrefix() {
    return "destination";
  }

  protected override DestinationInput toInput(const Destination e) {
    DestinationInput i;
    i.name = e.name;
    i.description = e.description;
    i.systemId = e.systemId.value;
    i.destinationType = cast(string) e.destinationType;
    i.url = e.url;
    i.authentication = cast(string) e.authentication;
    i.proxyType = cast(string) e.proxyType;
    i.locationId = e.locationId;
    i.user = e.user;
    i.tokenServiceUrl = e.tokenServiceUrl;
    i.audience = e.audience;
    i.scope_ = e.scope_;
    i.enabled = e.enabled;
    return i;
  }

  protected override void fromInput(TenantId t, ref Destination e, DestinationInput i, bool creating) {
    import std.uni : icmp;

    e.name = i.name.strip;
    foreach (other; repos.destinations.findAll(t))
      if (other.id != e.id && icmp(other.name, e.name) == 0)
        throw IaException.conflict("A destination named '" ~ e.name ~ "' already exists ('" ~ other.id.value ~ "')");
    e.description = i.description.strip;
    e.systemId = SystemConnectionId(optionalReference!SystemConnectionId(repos.systems, t, i.systemId, "System"));
    e.destinationType = parseDomainEnum!DestinationType(i.destinationType, "destination type");
    e.url = i.url.strip;
    e.authentication = parseDomainEnum!AuthenticationType(i.authentication, "authentication");
    e.proxyType = parseDomainEnum!ProxyType(i.proxyType, "proxy type");
    e.locationId = i.locationId.strip;
    e.user = i.user.strip;
    e.tokenServiceUrl = i.tokenServiceUrl.strip;
    e.audience = i.audience.strip;
    e.scope_ = i.scope_.strip;
    e.enabled = i.enabled;
  }

  protected override void beforeRemove(TenantId t, const Destination e, UserId actor) {
    requireUnused("Destination '" ~ e.name ~ "'", repos.scenarioTasks.countByReference(t, "destinationId", e.id.value),
      "task templates");
    long open;
    foreach (task; repos.workflowTasks.findByReference(t, "destinationId", e.id.value))
      if (task.status == TaskStatus.pending || task.status == TaskStatus.inProgress || task.status == TaskStatus.failed)
        open++;
    requireUnused("Destination '" ~ e.name ~ "'", open, "open workflow tasks");
  }
}
