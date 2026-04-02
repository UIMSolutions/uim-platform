module uim.platform.content_agent.domain.services.package_assembler;

import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.entities.content_provider;
import uim.platform.content_agent.domain.types;

/// Result of a package assembly operation.
struct AssemblyResult
{
    bool valid;
    string[] errors;
    string[] resolvedDependencies;
    long estimatedSizeBytes;
}

/// Domain service: validates and assembles content items into a package.
struct PackageAssembler
{
    /// Validate that all items in the package are consistent and have their dependencies met.
    static AssemblyResult validate(const ref ContentPackage pkg, const ContentProvider[] providers)
    {
        string[] errors;
        string[] deps;

        if (pkg.name.length == 0)
            errors ~= "Package name is required";

        if (pkg.items.length == 0)
            errors ~= "Package must contain at least one content item";

        // Collect all item IDs in this package
        bool[string] itemIds;
        foreach (ref item; pkg.items)
        {
            if (item.id in itemIds)
                errors ~= "Duplicate content item: " ~ item.name;
            itemIds[item.id] = true;
        }

        // Validate dependencies
        foreach (ref item; pkg.items)
        {
            foreach (ref dep; item.dependencies)
            {
                if (dep !in itemIds)
                {
                    deps ~= dep;
                }
            }
        }

        // Validate provider references
        bool[string] providerIds;
        foreach (ref p; providers)
            providerIds[p.id] = true;

        foreach (ref item; pkg.items)
        {
            if (item.providerId.length > 0 && item.providerId !in providerIds)
                errors ~= "Item '" ~ item.name ~ "' references unknown provider: " ~ item.providerId;
        }

        long size = 0;
        foreach (ref item; pkg.items)
            size += 1024; // estimated per-item overhead

        return AssemblyResult(errors.length == 0, errors, deps, size);
    }

    /// Validate that a provider is active and reachable.
    static bool isProviderUsable(const ref ContentProvider provider)
    {
        return provider.status == ProviderStatus.active
            && provider.endpoint.length > 0;
    }
}
