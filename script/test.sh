#!/bin/bash
#
# ================================================================================
# This script uses several containers:
# - radiusd: exists for test purposes only; acts as radius server for primary auth
# - radclient: exists for test purposes only; acts as "application or service"
# - duoauthproxy_1: uses duo integration that "allows" authentication
# - duoauthproxy_2: uses duo integration that "denies" authentication
#
# We test against the "internal" docker IPs (i.e., 172.17.42.0/24) to
# avoid challenges with NAT and RADIUS.
#
# Docker uses static NAT, which means services that do not reside on the same
# host as the authproxy container work fine. However, containers and processes
# on the same host as authproxy container source from 172.17.42.0/24.
#
# See http://docstore.mik.ua/orelly/networking_2ndEd/fire/ch21_07.htm
# for more info on RADIUS and NAT.
#
# See https://docs.docker.com/articles/networking/#container-networking
# for more info on Docker networking.
# ================================================================================

# Any failure causes script to fail.
set -e

. script/functions
[[ -r environment ]] && . environment

if [[ "x" = "x${RADIUS_TAG}" ]]; then
  # Use optimistic version if...
  # - user did not specify in `environment`, and
  # - script is not running in circleci.
  RADIUS_TAG="latest"
fi

# We need radclient for testing.
smitty docker pull jumanjiman/radclient:${RADIUS_TAG}

# We need radiusd for testing.
smitty docker pull jumanjiman/radiusd:${RADIUS_TAG}

# Re-tag the radius images to keep the test script simple.
smitty docker tag -f jumanjiman/radclient:${RADIUS_TAG} radclient
smitty docker tag -f jumanjiman/radiusd:${RADIUS_TAG} radiusd

bats test/test_*.bats
