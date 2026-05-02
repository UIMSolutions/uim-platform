/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.communication_arrangements;

// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.communication_arrangement;
// import uim.platform.abap_environment.domain.ports.repositories.communication_arrangements;
// import uim.platform.abap_environment.domain.types;

// import std.conv : to;
// import std.uuid : randomUUID;
import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:
/// Application service for communication arrangement CRUD.
class ManageCommunicationArrangementsUseCase { // TODO: UIMUseCase {
  private CommunicationArrangementRepository repo;

  this(CommunicationArrangementRepository repo) {
    this.repo = repo;
  }

  CommandResult createArrangement(CreateCommunicationArrangementRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Arrangement name is required");
    if (req.scenarioId.isEmpty)
      return CommandResult(false, "", "Communication scenario ID is required");
    if (req.systemInstanceId.isEmpty)
      return CommandResult(false, "", "System instance ID is required");

    CommunicationArrangement arr;
    arr.id = randomUUID();
    arr.tenantId = req.tenantId;
    arr.systemInstanceId = req.systemInstanceId;
    arr.scenarioId = req.scenarioId;
    arr.name = req.name;
    arr.description = req.description;
    arr.direction = parseDirection(req.direction);
    arr.status = ArrangementStatus.active;
    arr.authMethod = parseAuthMethod(req.authMethod);
    arr.communicationUser = req.communicationUser;
    arr.communicationPassword = req.communicationPassword;
    arr.clientId = req.clientId;
    arr.clientSecret = req.clientSecret;
    arr.tokenEndpoint = req.tokenEndpoint;
    arr.certificateId = req.certificateId;
    arr.inboundServices = req.inboundServices;
    arr.outboundServices = req.outboundServices;

    // import std.datetime.systime : Clock;
    arr.createdAt = Clock.currStdTime();
    arr.updatedAt = arr.createdAt;

    repo.save(arr);
    return CommandResult(true, arr.id.value, "");
  }

  CommandResult updateArrangement(CommunicationArrangementId id,
    UpdateCommunicationArrangementRequest req) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Communication arrangement not found");

    auto arr = repo.findById(id);
    if (req.description.length > 0)
      arr.description = req.description;
    if (req.status.length > 0)
      arr.status = req.status.to!ArrangementStatus;
    if (req.authMethod.length > 0)
      arr.authMethod = req.authMethod.to!CommunicationAuthMethod;
    if (req.communicationUser.length > 0)
      arr.communicationUser = req.communicationUser;
    if (req.communicationPassword.length > 0)
      arr.communicationPassword = req.communicationPassword;
    if (req.clientId.length > 0)
      arr.clientId = req.clientId;
    if (req.clientSecret.length > 0)
      arr.clientSecret = req.clientSecret;
    if (req.tokenEndpoint.length > 0)
      arr.tokenEndpoint = req.tokenEndpoint;
    if (req.inboundServices.length > 0)
      arr.inboundServices = req.inboundServices;
    if (req.outboundServices.length > 0)
      arr.outboundServices = req.outboundServices;

    // import std.datetime.systime : Clock;
    arr.updatedAt = Clock.currStdTime();

    repo.update(arr);
    return CommandResult(true, arr.id.value, "");
  }

  CommunicationArrangement* getArrangement(CommunicationArrangementId id) {
    return repo.findById(id);
  }

  CommunicationArrangement[] listArrangements(SystemInstanceId systemId) {
    return repo.findBySystem(systemId);
  }

  CommandResult deleteArrangement(CommunicationArrangementId id) {
    auto arrangement = repo.findById(id);
    if (arrangement.isNull)      
      return CommandResult(false, "", "Communication arrangement not found");

    repo.remove(arrangement);
    return CommandResult(true, arrangement.id.value, "");
  }
}


