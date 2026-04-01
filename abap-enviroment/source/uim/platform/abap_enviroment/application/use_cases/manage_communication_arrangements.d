module uim.platform.abap_enviroment.application.use_cases.manage_communication_arrangements;

import uim.platform.abap_enviroment.application.dto;
import uim.platform.abap_enviroment.domain.entities.communication_arrangement;
import uim.platform.abap_enviroment.domain.ports.communication_arrangement_repository;
import uim.platform.abap_enviroment.domain.types;

import std.conv : to;
import std.uuid : randomUUID;

/// Application service for communication arrangement CRUD.
class ManageCommunicationArrangementsUseCase
{
    private CommunicationArrangementRepository repo;

    this(CommunicationArrangementRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createArrangement(CreateCommunicationArrangementRequest req)
    {
        if (req.name.length == 0)
            return CommandResult("", "Arrangement name is required");
        if (req.scenarioId.length == 0)
            return CommandResult("", "Communication scenario ID is required");
        if (req.systemInstanceId.length == 0)
            return CommandResult("", "System instance ID is required");

        auto id = randomUUID().toString();
        CommunicationArrangement arr;
        arr.id = id;
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

        import std.datetime.systime : Clock;
        arr.createdAt = Clock.currStdTime();
        arr.updatedAt = arr.createdAt;

        repo.save(arr);
        return CommandResult(id, "");
    }

    CommandResult updateArrangement(CommunicationArrangementId id, UpdateCommunicationArrangementRequest req)
    {
        auto arr = repo.findById(id);
        if (arr is null)
            return CommandResult("", "Communication arrangement not found");

        if (req.description.length > 0) arr.description = req.description;
        if (req.status.length > 0) arr.status = parseArrangementStatus(req.status);
        if (req.authMethod.length > 0) arr.authMethod = parseAuthMethod(req.authMethod);
        if (req.communicationUser.length > 0) arr.communicationUser = req.communicationUser;
        if (req.communicationPassword.length > 0) arr.communicationPassword = req.communicationPassword;
        if (req.clientId.length > 0) arr.clientId = req.clientId;
        if (req.clientSecret.length > 0) arr.clientSecret = req.clientSecret;
        if (req.tokenEndpoint.length > 0) arr.tokenEndpoint = req.tokenEndpoint;
        if (req.inboundServices.length > 0) arr.inboundServices = req.inboundServices;
        if (req.outboundServices.length > 0) arr.outboundServices = req.outboundServices;

        import std.datetime.systime : Clock;
        arr.updatedAt = Clock.currStdTime();

        repo.update(*arr);
        return CommandResult(id, "");
    }

    CommunicationArrangement* getArrangement(CommunicationArrangementId id)
    {
        return repo.findById(id);
    }

    CommunicationArrangement[] listArrangements(SystemInstanceId systemId)
    {
        return repo.findBySystem(systemId);
    }

    CommandResult deleteArrangement(CommunicationArrangementId id)
    {
        auto arr = repo.findById(id);
        if (arr is null)
            return CommandResult("", "Communication arrangement not found");

        repo.remove(id);
        return CommandResult(id, "");
    }
}

private CommunicationDirection parseDirection(string s)
{
    switch (s)
    {
    case "inbound": return CommunicationDirection.inbound;
    case "outbound": return CommunicationDirection.outbound;
    default: return CommunicationDirection.inbound;
    }
}

private CommunicationAuthMethod parseAuthMethod(string s)
{
    switch (s)
    {
    case "basicAuthentication": return CommunicationAuthMethod.basicAuthentication;
    case "oauth2ClientCredentials": return CommunicationAuthMethod.oauth2ClientCredentials;
    case "oauth2SAMLBearerAssertion": return CommunicationAuthMethod.oauth2SAMLBearerAssertion;
    case "clientCertificate": return CommunicationAuthMethod.clientCertificate;
    case "noAuthentication": return CommunicationAuthMethod.noAuthentication;
    default: return CommunicationAuthMethod.basicAuthentication;
    }
}

private ArrangementStatus parseArrangementStatus(string s)
{
    switch (s)
    {
    case "active": return ArrangementStatus.active;
    case "inactive": return ArrangementStatus.inactive;
    case "error": return ArrangementStatus.error;
    default: return ArrangementStatus.active;
    }
}
