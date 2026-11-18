
# AGENTS.md: Agent instructions for an 'R Billboard API' package

Task: write a small R package that can access the Billboard Music API at RapidAPI.com

## Billboard Access

Interface the API exposed via https://rapidapi.com. An example call for
datafrom 2026-11-10 covering ten from the top 100 and using 'RAPIDAPI_KEY' is

```sh
curl --request GET \
	--url 'https://billboard-api2.p.rapidapi.com/hot-100?date=2026-11-10&range=1-10' \
	--header 'x-rapidapi-host: billboard-api2.p.rapidapi.com' \
	--header "x-rapidapi-key: ${RAPIDAPI_KEY}"
```

where the RAPIDAPI_KEY variable should be set.

## Packaging Guidance

- Use devtools, usethis, roxygen2, testthat, ... as needed as they are installed
- If in doubt, be frugal and try to use base R.
- For Authors@R in DESCRIPTION use 'person("Dirk", "Eddelbuettel", role = c("aut", "cre"),
email = "edd@debian.org", comment = c(ORCID = "0000-0001-6419-907X"))'
- Use 'GPL (>= 2)' as the default license
- Use '0.0.1' as the initial version number
- You can install additional or local R packages in directory ../lib/.  
- Do NOT install system packages. If something is missing, say so and halt.
- Do not bother with a vignette in a first instance of the package.
- Turn that example `curl` call into an R function, and wrap it in a minimal
  R package. 
- Call the package 'rbillboard'.
- Place the package and its files in a subdirectory 'rbillboard' in the working directory.
- The 'httr' package should be sufficient to access the REST API. Use one of the JSON
  parsing packages (for example 'jsonlite') to turn the response into a data.frame and
  write that data.frame (time-stamped) as both a csv file and a rds file.
- The package should pass 'R CMD check'.
- The API at rapidapi.com has a (monthly and daily) limit on requests so try not to call
  too often. Maybe for tests call one, store the result and have tests use it.
- The `RAPIDAPI_KEY` environment variable is not set. The shell script `curlExample.sh`
  has been used to create response data in file `response.json`. Use this for tests.
- If there is something you are unsure about, leave a 'TODO' item.  Do not speculate.
