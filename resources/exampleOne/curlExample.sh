#!/bin/sh

curl --request GET \
	--url 'https://billboard-api2.p.rapidapi.com/hot-100?date=2026-11-10&range=1-10' \
	--header 'x-rapidapi-host: billboard-api2.p.rapidapi.com' \
	--header "x-rapidapi-key: ${RAPIDAPI_KEY}" > response.json
