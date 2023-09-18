# SPDX-License-Identifier: MIT
#
# SPDX-FileCopyrightText: Copyright (c) 2019-2023 Lars Melchior and contributors

set(CPM_DOWNLOAD_VERSION 1.0.0-development-version)
set(CPM_HASH_SUM "CPM_HASH_SUM_PLACEHOLDER")

if(CPM_SOURCE_CACHE)
  set(CPM_DOWNLOAD_LOCATION "${CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
elseif(DEFINED ENV{CPM_SOURCE_CACHE})
  set(CPM_DOWNLOAD_LOCATION "$ENV{CPM_SOURCE_CACHE}/cpm/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
else()
  set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
endif()

# Expand relative path. This is important if the provided path contains a tilde (~)
get_filename_component(CPM_DOWNLOAD_LOCATION ${CPM_DOWNLOAD_LOCATION} ABSOLUTE)

message(STATUS "Using CPM at ${CPM_DOWNLOAD_LOCATION}")

file(
  DOWNLOAD
  https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
  ${CPM_DOWNLOAD_LOCATION}
  STATUS CPM_DOWNLOAD_STATUS
  EXPECTED_HASH SHA256=${CPM_HASH_SUM}
)

list(GET CPM_DOWNLOAD_STATUS 0 CPM_DOWNLOAD_STATUS_CODE)
if(NOT ${CPM_DOWNLOAD_STATUS_CODE} EQUAL 0)
  # give a fatal error when download fails
  list(GET CPM_DOWNLOAD_STATUS 1 CPM_DOWNLOAD_ERROR_MESSAGE)
  message(FATAL_ERROR "Error occurred during download of CPM: ${CPM_DOWNLOAD_ERROR_MESSAGE}")
endif()

include(${CPM_DOWNLOAD_LOCATION})
