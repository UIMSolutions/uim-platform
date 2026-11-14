/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.backend_connections;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageBackendConnectionsUseCase : IManageBackendConnectionsUseCase {
  protected IBackendConnectionRepository repo;
  protected IBackendProbe probe;
  protected IAgentryEventPublisher events;

  /// probe may be null — testBackendConnection then reports "not configured".
  this(IBackendConnectionRepository repo, IBackendProbe probe = null, IAgentryEventPublisher events = null) {
    this.repo = repo;
    this.probe = probe;
    this.events = events is null ? new NullEventPublisher : events;
  }

  BackendConnection[] listBackendConnections(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  BackendConnection[] listByBackendType(TenantId tenantId, BackendType backendType) {
    return repo.findByBackendType(tenantId, backendType);
  }

  BackendConnection[] listByStatus(TenantId tenantId, ConnectionStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  BackendConnection getBackendConnection(TenantId tenantId, BackendConnectionId id) {
    return repo.findById(tenantId, id);
  }

  UsecaseResult createBackendConnection(BackendConnectionDTO dto) {
    if (!dto.connectionId.isNull && repo.existsById(dto.tenantId, dto.connectionId))
      return conflict("Backend connection '" ~ dto.connectionId.value ~ "' already exists");

    auto conn = newEntity!(BackendConnection)(dto.tenantId, dto.connectionId, dto.createdBy);
    conn.status = ConnectionStatus.inactive;
    string[] errors;
    apply(conn, dto, errors);
    errors ~= AgentryValidator.validate(conn);
    if (errors.length)
      return invalid(errors);
    if (repo.findByTenant(dto.tenantId).any!(c => c.name == conn.name))
      return conflict("A backend connection named '" ~ conn.name ~ "' already exists");

    repo.save(conn);
    return created(conn.id.value, "Backend connection created");
  }

  UsecaseResult updateBackendConnection(BackendConnectionDTO dto) {
    auto conn = repo.findById(dto.tenantId, dto.connectionId);
    if (conn.isNull)
      return notFound("Backend connection", dto.connectionId.value);

    auto oldUrl = conn.backendUrl;
    string[] errors;
    apply(conn, dto, errors);
    errors ~= AgentryValidator.validate(conn);
    if (errors.length)
      return invalid(errors);
    // a changed endpoint invalidates the last test result
    if (conn.backendUrl != oldUrl && dto.status.length == 0)
      conn.status = ConnectionStatus.inactive;

    touch(conn, dto.updatedBy);
    repo.update(conn);
    return succeeded(conn.id.value, "Backend connection updated");
  }

  UsecaseResult testBackendConnection(TenantId tenantId, BackendConnectionId id, UserId by) {
    auto conn = repo.findById(tenantId, id);
    if (conn.isNull)
      return notFound("Backend connection", id.value);

    BackendProbeResult probeResult;
    if (probe is null)
      probeResult = BackendProbeResult(false, 0, 0, "No connectivity probe configured");
    else {
      try
        probeResult = probe.probe(conn);
      catch (Exception e)
        probeResult = BackendProbeResult(false, 0, 0, e.msg);
    }

    conn.status = probeResult.reachable ? ConnectionStatus.active : ConnectionStatus.error;
    conn.lastTestedAt = nowStdTime();
    conn.lastTestedBy = by.value;
    touch(conn, by);
    repo.update(conn);

    auto data = Json.emptyObject
      .set("reachable", probeResult.reachable)
      .set("statusCode", probeResult.statusCode)
      .set("latencyMs", probeResult.latencyMs)
      .set("message", probeResult.message);
    events.publish(AgentryTopics.connectionTested, data.clone.set("tenantId", tenantId.value).set("id", id.value));
    return succeeded(conn.id.value, probeResult.reachable
        ? "Backend reachable (%d ms)".format(probeResult.latencyMs)
        : "Backend not reachable: " ~ probeResult.message, 200, data);
  }

  UsecaseResult deleteBackendConnection(TenantId tenantId, BackendConnectionId id) {
    auto conn = repo.findById(tenantId, id);
    if (conn.isNull)
      return notFound("Backend connection", id.value);
    repo.remove(conn);
    return succeeded(conn.id.value, "Backend connection deleted");
  }

  protected void apply(ref BackendConnection conn, const BackendConnectionDTO dto, ref string[] errors) {
    assignIf(conn.name, dto.name);
    assignIf(conn.description, dto.description);
    assignIf(conn.backendUrl, dto.backendUrl);
    assignIf(conn.clientId, dto.clientId);
    assignIf(conn.authMethod, dto.authMethod);
    assignIf(conn.sysId, dto.sysId);
    assignIf(conn.sysNumber, dto.sysNumber);
    assignIf(conn.client, dto.client);
    assignIf(conn.language, dto.language);
    assignIf(conn.destinationName, dto.destinationName);
    assignIf(conn.certificateFingerprint, dto.certificateFingerprint);
    conn.sslEnabled = dto.sslEnabled;
    readEnum(dto.backendType, conn.backendType, "backendType", errors);
    readEnum(dto.status, conn.status, "status", errors);
  }
}

///
unittest {
  mixin(ShowTest!("ManageBackendConnectionsUseCase"));

  class FakeProbe : IBackendProbe {
    BackendProbeResult probe(const BackendConnection c) {
      return BackendProbeResult(c.backendUrl.canFind("ok"), 200, 12, "HTTP 200");
    }
  }

  auto uc = new ManageBackendConnectionsUseCase(new BackendConnectionRepository(), new FakeProbe);
  auto t = TenantId("t1");
  BackendConnectionDTO dto;
  dto.tenantId = t;
  dto.name = "S/4HANA QA";
  dto.backendUrl = "https://ok.example.com";
  dto.backendType = "s4hana";
  dto.authMethod = "oauth2";
  dto.sslEnabled = true;
  auto r = uc.createBackendConnection(dto);
  assert(r.isSuccess, r.message);
  auto id = BackendConnectionId(r.id);
  assert(uc.createBackendConnection(dto).code == 409);

  auto tested = uc.testBackendConnection(t, id, UserId("admin"));
  assert(tested.isSuccess && tested.data["reachable"].get!bool);
  assert(uc.getBackendConnection(t, id).status == ConnectionStatus.active);
  assert(uc.getBackendConnection(t, id).lastTestedBy == "admin");

  dto.connectionId = id;
  dto.backendUrl = "https://down.example.com";
  assert(uc.updateBackendConnection(dto).isSuccess);
  assert(uc.getBackendConnection(t, id).status == ConnectionStatus.inactive);
  uc.testBackendConnection(t, id, UserId("admin"));
  assert(uc.getBackendConnection(t, id).status == ConnectionStatus.error);
}
