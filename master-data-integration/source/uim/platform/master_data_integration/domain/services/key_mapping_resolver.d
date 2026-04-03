module domain.services.key_mapping_resolver;

import domain.entities.key_mapping;
import domain.types;

/// Domain service: resolves cross-system key mappings.
class KeyMappingResolver
{
    /// Find the local key for a specific client within a key mapping.
    string resolveLocalKey(KeyMapping mapping, ClientId clientId)
    {
        foreach (ref entry; mapping.entries)
        {
            if (entry.clientId == clientId)
                return entry.localKey;
        }
        return "";
    }

    /// Find the primary key entry within a mapping.
    KeyMappingEntry findPrimaryEntry(KeyMapping mapping)
    {
        foreach (ref entry; mapping.entries)
        {
            if (entry.isPrimary)
                return entry;
        }
        return KeyMappingEntry.init;
    }

    /// Check if a mapping contains a given client.
    bool hasClientMapping(KeyMapping mapping, ClientId clientId)
    {
        foreach (ref entry; mapping.entries)
        {
            if (entry.clientId == clientId)
                return true;
        }
        return false;
    }

    /// Validate that a key mapping has at least one primary entry.
    bool isValid(KeyMapping mapping)
    {
        if (mapping.entries.length == 0)
            return false;

        bool hasPrimary = false;
        foreach (ref entry; mapping.entries)
        {
            if (entry.isPrimary)
            {
                if (hasPrimary) return false;   // Only one primary allowed
                hasPrimary = true;
            }
            if (entry.localKey.length == 0)
                return false;
        }
        return hasPrimary;
    }
}
