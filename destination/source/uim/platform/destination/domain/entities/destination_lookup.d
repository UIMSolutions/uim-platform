module uim.platform.destination.domain.entities.destination_lookup;

import uim.platform.destination.domain.types;
import uim.platform.destination.domain.entities.destination;
import uim.platform.destination.domain.entities.auth_token;
import uim.platform.destination.domain.entities.certificate;

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

import uim.platform.destination.domain.entities.destination_fragment;
