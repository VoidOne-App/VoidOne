cmake_minimum_required(VERSION 4.4.2)

set(VOIDONE_VERSION_OVERRIDE "0.0.1" CACHE STRING "Override application version (normally supplied by CI/tag)")
set(VOIDONE_VERSION_INPUT "${VOIDONE_VERSION_OVERRIDE}")
string(REGEX MATCH "^[0-9]+\.[0-9]+\.[0-9]+" VOIDONE_VERSION_BASE "${VOIDONE_VERSION_INPUT}")