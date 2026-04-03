module domain.entities.destination_lookup;

import domain.types;
import domain.entities.destination;
import domain.entities.auth_token;
import domain.entities.certificate;

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

import domain.entities.destination_fragment;
