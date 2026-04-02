module domain.services.environment_provisioner;

import uim.platform.management.domain.entities.environment_instance;
import uim.platform.management.domain.entities.subaccount;
import uim.platform.management.domain.types;

/// Domain service: validates environment provisioning constraints.
class EnvironmentProvisioner
{
    /// Validate that an environment can be provisioned in the given subaccount.
    ProvisionValidation validateProvisioning(
        EnvironmentType envType, string planName,
        Subaccount subaccount, EnvironmentInstance[] existingInstances)
    {
        ProvisionValidation v;
        v.valid = true;

        // Subaccount must be active
        if (subaccount.status != SubaccountStatus.active)
        {
            v.valid = false;
            v.reason = "Subaccount must be in active status to provision environments";
            return v;
        }

        // Check for duplicate environment types (only one CF org per subaccount)
        if (envType == EnvironmentType.cloudFoundry)
        {
            foreach (ref inst; existingInstances)
            {
                if (inst.environmentType == EnvironmentType.cloudFoundry
                    && inst.status != EnvironmentStatus.deleting
                    && inst.status != EnvironmentStatus.error)
                {
                    v.valid = false;
                    v.reason = "Only one Cloud Foundry environment allowed per subaccount";
                    return v;
                }
            }
        }

        // Validate plan name is not empty
        if (planName.length == 0)
        {
            v.valid = false;
            v.reason = "Plan name is required for environment provisioning";
            return v;
        }

        return v;
    }

    /// Determine if an environment can be deleted.
    bool canDelete(EnvironmentInstance inst)
    {
        return inst.status == EnvironmentStatus.active
            || inst.status == EnvironmentStatus.error
            || inst.status == EnvironmentStatus.suspended;
    }
}

/// Result of provisioning validation.
struct ProvisionValidation
{
    bool valid;
    string reason;
}
