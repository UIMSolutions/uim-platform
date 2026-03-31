module domain.services.system_lifecycle_validator;

import domain.types;

/// Validation result for system lifecycle transitions.
struct LifecycleValidation
{
    bool valid;
    string error;
}

/// Domain service: validates system instance state transitions.
struct SystemLifecycleValidator
{
    /// Check whether a status transition is permitted.
    static LifecycleValidation validateTransition(SystemStatus from, SystemStatus to)
    {
        // Allowed transitions:
        //   provisioning -> active | error
        //   active       -> updating | suspended | deleting
        //   updating     -> active | error
        //   suspended    -> active | deleting
        //   deleting     -> deleted | error
        //   error        -> deleting

        switch (from)
        {
        case SystemStatus.provisioning:
            if (to == SystemStatus.active || to == SystemStatus.error)
                return LifecycleValidation(true, "");
            break;
        case SystemStatus.active:
            if (to == SystemStatus.updating || to == SystemStatus.suspended || to == SystemStatus.deleting)
                return LifecycleValidation(true, "");
            break;
        case SystemStatus.updating:
            if (to == SystemStatus.active || to == SystemStatus.error)
                return LifecycleValidation(true, "");
            break;
        case SystemStatus.suspended:
            if (to == SystemStatus.active || to == SystemStatus.deleting)
                return LifecycleValidation(true, "");
            break;
        case SystemStatus.deleting:
            if (to == SystemStatus.deleted || to == SystemStatus.error)
                return LifecycleValidation(true, "");
            break;
        case SystemStatus.error:
            if (to == SystemStatus.deleting)
                return LifecycleValidation(true, "");
            break;
        default:
            break;
        }

        import std.conv : to;
        return LifecycleValidation(false,
            "Invalid transition from '" ~ from.to!string ~ "' to '" ~ to.to!string ~ "'");
    }

    /// Validate that a system SID is exactly 3 uppercase characters.
    static LifecycleValidation validateSid(string sid)
    {
        if (sid.length != 3)
            return LifecycleValidation(false, "SAP System ID must be exactly 3 characters");

        foreach (c; sid)
        {
            if (c < 'A' || c > 'Z')
                return LifecycleValidation(false, "SAP System ID must contain only uppercase letters");
        }

        return LifecycleValidation(true, "");
    }
}
