module uim.platform.data.quality.domain.services.address_cleanser;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.address_record;

// import std.uni : toUpper, toLower, isAlpha, isWhite;
// import std.string : strip, toUpper, toLower;
// import std.array : replace;
// import std.datetime.systime : Clock;

/// Domain service - cleanses and standardizes address data.
class AddressCleanser
{
    /// Cleanse a raw address record, returning the corrected version.
    AddressRecord cleanse(AddressRecord input)
    {
        auto record = input;
        CleansingAction[] actions;
        string[] changes;

        // 1. Trim whitespace
        record.line1 = strip(input.inputLine1);
        record.line2 = strip(input.inputLine2);
        record.city = strip(input.inputCity);
        record.region = strip(input.inputRegion);
        record.postalCode = strip(input.inputPostalCode);
        record.country = strip(input.inputCountry);

        if (record.line1 != input.inputLine1
            || record.city != input.inputCity)
        {
            actions ~= CleansingAction.trimmed;
            changes ~= "Trimmed whitespace";
        }

        // 2. Normalize case - Title case for city / region, upper for country
        if (record.city.length > 0)
        {
            auto normalized = titleCase(record.city);
            if (normalized != record.city)
            {
                record.city = normalized;
                actions ~= CleansingAction.normalized;
                changes ~= "Normalized city case";
            }
        }

        if (record.region.length > 0)
        {
            auto normalized = titleCase(record.region);
            if (normalized != record.region)
            {
                record.region = normalized;
                changes ~= "Normalized region case";
            }
        }

        // 3. Standardize country to uppercase ISO
        if (record.country.length > 0)
        {
            auto iso = standardizeCountry(record.country);
            if (iso != record.country)
            {
                record.country = iso;
                record.countryIso2 = iso.length == 2 ? iso : "";
                actions ~= CleansingAction.standardized;
                changes ~= "Standardized country code";
            }
        }

        // 4. Standardize postal code
        if (record.postalCode.length > 0)
        {
            auto standardized = standardizePostalCode(
                record.postalCode, record.countryIso2);
            if (standardized != record.postalCode)
            {
                record.postalCode = standardized;
                changes ~= "Standardized postal code";
            }
        }

        // 5. Standardize common address abbreviations
        if (record.line1.length > 0)
        {
            auto standardized = standardizeAbbreviations(record.line1);
            if (standardized != record.line1)
            {
                record.line1 = standardized;
                actions ~= CleansingAction.standardized;
                changes ~= "Standardized address abbreviations";
            }
        }

        // Determine quality
        record.quality = assessQuality(record);
        record.appliedActions = actions;
        record.changeLog = changes;
        record.cleansedAt = Clock.currStdTime();

        return record;
    }

    private AddressQuality assessQuality(ref const AddressRecord r)
    {
        // Simple quality heuristic
        if (r.line1.length > 0 && r.city.length > 0
            && r.postalCode.length > 0 && r.country.length > 0)
            return AddressQuality.corrected;

        if (r.line1.length > 0 && r.city.length > 0)
            return AddressQuality.partial;

        return AddressQuality.unverifiable;
    }

    private static string titleCase(string s)
    {
        char[] result;
        result.length = s.length;
        bool capitalize = true;
        foreach (i, c; s)
        {
            if (isWhite(c) || c == '-' || c == '\'')
            {
                result[i] = c;
                capitalize = true;
            }
            else if (capitalize && isAlpha(c))
            {
                result[i] = cast(char) toUpper(cast(dchar) c);
                capitalize = false;
            }
            else
            {
                result[i] = cast(char) toLower(cast(dchar) c);
                capitalize = false;
            }
        }
        return cast(string) result;
    }

    private static string standardizeCountry(string country)
    {
        // Common country name to ISO-2 mapping
        auto upper = country.toUpper();
        if (upper.length == 2)
            return upper;

        switch (upper)
        {
            case "GERMANY", "DEUTSCHLAND": return "DE";
            case "UNITED STATES", "USA", "US", "U.S.A.": return "US";
            case "UNITED KINGDOM", "UK", "GREAT BRITAIN", "GB": return "GB";
            case "FRANCE", "FRANKREICH": return "FR";
            case "SWITZERLAND", "SCHWEIZ", "SUISSE": return "CH";
            case "AUSTRIA", "OESTERREICH": return "AT";
            case "NETHERLANDS", "NIEDERLANDE", "HOLLAND": return "NL";
            case "ITALY", "ITALIEN", "ITALIA": return "IT";
            case "SPAIN", "SPANIEN", "ESPANA": return "ES";
            case "CANADA": return "CA";
            case "AUSTRALIA": return "AU";
            case "JAPAN": return "JP";
            case "CHINA": return "CN";
            case "INDIA": return "IN";
            case "BRAZIL", "BRASILIEN": return "BR";
            default: return country;
        }
    }

    private static string standardizePostalCode(string code, string countryIso2)
    {
        // import std.string : strip;

        auto cleaned = code.strip();

        // Remove spaces for compact codes (DE, US)
        if (countryIso2 == "DE" || countryIso2 == "US")
            cleaned = cleaned.replace(" ", "");

        // UK postal codes: ensure space
        if (countryIso2 == "GB" && cleaned.length >= 5)
        {
            auto noSpace = cleaned.replace(" ", "");
            if (noSpace.length >= 5)
            {
                auto inward = noSpace[$ - 3 .. $];
                auto outward = noSpace[0 .. $ - 3];
                cleaned = outward ~ " " ~ inward;
            }
        }

        return cleaned.toUpper();
    }

    private static string standardizeAbbreviations(string line)
    {
        string result = line;
        // Common address abbreviations
        result = result.replace("Str.", "Street");
        result = result.replace("str.", "Street");
        result = result.replace("Ave.", "Avenue");
        result = result.replace("ave.", "Avenue");
        result = result.replace("Blvd.", "Boulevard");
        result = result.replace("blvd.", "Boulevard");
        result = result.replace("Dr.", "Drive");
        result = result.replace("Ln.", "Lane");
        result = result.replace("Rd.", "Road");
        result = result.replace("rd.", "Road");
        result = result.replace("Ct.", "Court");
        result = result.replace("Pl.", "Place");
        result = result.replace("Apt.", "Apartment");
        result = result.replace("apt.", "Apartment");
        result = result.replace("Ste.", "Suite");
        result = result.replace("ste.", "Suite");
        return result;
    }
}
