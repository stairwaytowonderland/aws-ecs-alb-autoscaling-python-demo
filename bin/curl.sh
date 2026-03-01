#!/bin/sh

# Advanced healthcheck - returns HTTP 200 OK if everything is working and some service details
curl -X GET -H "Content-Type: application/json" http://localhost:8000/gtg?details

# Adds a new string (candidate name) to a list, returns HTTP 200 OK if working
curl -X POST -H "Content-Type: application/json" http://localhost:8000/candidate/Peter%20Parker

# optional parameter ?party=<empty|ind|dem|rep>
curl -X POST -H "Content-Type: application/json" http://localhost:8000/candidate/Tony%20Stark?party=yes

# Gets candidate name from the list, returns HTTP 200 OK and data
curl -X GET -H "Content-Type: application/json" http://localhost:8000/candidate/Peter%20Parker

# Gets candidate name (with a party) from the list, returns HTTP 200 OK and data
curl -X GET -H "Content-Type: application/json" http://localhost:8000/candidate/Tony%20Stark

# Gets list of all candidates from a list, returns HTTP 200 OK and data
curl -X GET -H "Content-Type: application/json" http://localhost:8000/candidates