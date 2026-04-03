module uim.platform.xyz.domain.entities.destination_lookup;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.destination;
import uim.platform.xyz.domain.entities.auth_token;
import uim.platform.xyz.domain.entities.certificate;

/// The result of a "find destination" lookup — includes destination config, resolved auth tokens, and certificates.
struct DestinationLookup
{
    Destination destination;
    AuthToken[] authTokens;
    Certificate[] certificates;
    DestinationFragment[] appliedFragments;
    bool found;
    string error;
}

import uim.platform.xyz.domain.entities.destination_fragment;
