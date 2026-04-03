module application.usecases.manage_fragments;

import application.dto;
import domain.entities.destination_fragment;
import domain.ports.fragment_repository;
import domain.types;

import std.conv : to;

/// Application service for destination fragment CRUD operations.
class ManageFragmentsUseCase
{
    private FragmentRepository repo;

    this(FragmentRepository repo)
    {
        this.repo = repo;
    }

    CommandResult create(CreateFragmentRequest req)
    {
        if (req.name.length == 0)
            return CommandResult(false, "", "Fragment name is required");

        auto existing = repo.findByName(req.tenantId, req.subaccountId, req.name);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Fragment '" ~ req.name ~ "' already exists");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        DestinationFragment f;
        f.id = id;
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
        f.modifiedAt = f.createdAt;

        repo.save(f);
        return CommandResult(true, id, "");
    }

    CommandResult updateFragment(FragmentId id, UpdateFragmentRequest req)
    {
        auto f = repo.findById(id);
        if (f.id.length == 0)
            return CommandResult(false, "", "Fragment not found");

        if (req.description.length > 0) f.description = req.description;
        if (req.url.length > 0) f.url = req.url;
        if (req.authenticationType.length > 0) f.authenticationType = req.authenticationType;
        if (req.proxyType.length > 0) f.proxyType = req.proxyType;
        if (req.user.length > 0) f.user = req.user;
        if (req.password.length > 0) f.password = req.password;
        if (req.clientId.length > 0) f.clientId = req.clientId;
        if (req.clientSecret.length > 0) f.clientSecret = req.clientSecret;
        if (req.tokenServiceUrl.length > 0) f.tokenServiceUrl = req.tokenServiceUrl;
        if (req.locationId.length > 0) f.locationId = req.locationId;
        if (req.keystoreId.length > 0) f.keystoreId = req.keystoreId;
        if (req.truststoreId.length > 0) f.truststoreId = req.truststoreId;
        if (req.properties.length > 0) f.properties = req.properties;
        f.modifiedAt = clockSeconds();

        repo.update(f);
        return CommandResult(true, id, "");
    }

    DestinationFragment getFragment(FragmentId id)
    {
        return repo.findById(id);
    }

    DestinationFragment[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId)
    {
        return repo.findBySubaccount(tenantId, subaccountId);
    }

    CommandResult removeFragment(FragmentId id)
    {
        auto f = repo.findById(id);
        if (f.id.length == 0)
            return CommandResult(false, "", "Fragment not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }

    private static long clockSeconds()
    {
        import std.datetime.systime : Clock;
        return Clock.currTime().toUnixTime();
    }

    private static DestinationLevel parseLevel(string s)
    {
        switch (s)
        {
            case "serviceInstance": return DestinationLevel.serviceInstance;
            default:               return DestinationLevel.subaccount;
        }
    }
}
