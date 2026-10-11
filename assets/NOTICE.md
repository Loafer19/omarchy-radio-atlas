# Map data

`countries.json` is built by `tools/build-countries.sh` from Natural Earth's
Admin 0 Countries data (v5.1.2). Geometry comes from the 1:50m dataset, simplified
topologically with mapshaper (`keep-shapes`, 15% of vertices) so shared
borders stay aligned. The country set and names follow the 1:110m dataset;
Somaliland and Northern Cyprus use the codes SO and CY.
Natural Earth data is in the public domain.

Source: https://www.naturalearthdata.com/

# Country search names

`country-search.json` maps lowercase names and codes to Radio Browser country
codes. It combines Radio Browser's country directory, retrieved on 2026-09-29,
with the labels in `countries.json` and the aliases `USA`, `United States`, `UK`,
and `Great Britain`. Entries without a name or a two-letter code are excluded.
The UI and fetch script share this bundled snapshot, so lookup works offline
without another network request. Update it when country names or codes change.

Source: https://de1.api.radio-browser.info/json/countries
