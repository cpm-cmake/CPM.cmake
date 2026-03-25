cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

# Random suffix
string(
  RANDOM
  LENGTH 6
  ALPHABET "0123456789abcdef" tmpdir_suffix
)

# Seconds since epoch
string(TIMESTAMP tmpdir_base "%s" UTC)

set(tmp "${CMAKE_CURRENT_BINARY_DIR}/get_shortest_hash-${tmpdir_base}-${tmpdir_suffix}")

if(IS_DIRECTORY ${tmp})
  message(FATAL_ERROR "Test directory ${tmp} already exists")
endif()

file(MAKE_DIRECTORY "${tmp}")

# 1. Sanity check: none of these directories should exist yet

assert_not_exists(${tmp}/cccb.hash)
assert_not_exists(${tmp}/cccb77ae.hash)
assert_not_exists(${tmp}/cccb77ae9609.hash)
assert_not_exists(${tmp}/cccb77ae9608.hash)
assert_not_exists(${tmp}/cccb77be.hash)

# 1. The directory is empty, so it should get a 4-character hash
cpm_get_shortest_hash(${tmp} "cccb77ae9609d2768ed80dd42cec54f77b1f1455" hash)
assert_equal(${hash} "cccb")
assert_contents_equal(${tmp}/cccb.hash cccb77ae9609d2768ed80dd42cec54f77b1f1455)

# 1. Calling the function with a new hash that differs subtly should result in more characters being
#   used, enough to uniquely identify the hash

cpm_get_shortest_hash(${tmp} "cccb77ae9609d2768ed80dd42cec54f77b1f1456" hash)
assert_equal(${hash} "cccb77ae")
assert_contents_equal(${tmp}/cccb77ae.hash cccb77ae9609d2768ed80dd42cec54f77b1f1456)

cpm_get_shortest_hash(${tmp} "cccb77ae9609d2768ed80dd42cec54f77b1f1457" hash)
assert_equal(${hash} "cccb77ae9609")
assert_contents_equal(${tmp}/cccb77ae9609.hash cccb77ae9609d2768ed80dd42cec54f77b1f1457)

cpm_get_shortest_hash(${tmp} "cccb77ae9608d2768ed80dd42cec54f77b1f1455" hash)
assert_equal(${hash} "cccb77ae9608")
assert_contents_equal(${tmp}/cccb77ae9608.hash cccb77ae9608d2768ed80dd42cec54f77b1f1455)

cpm_get_shortest_hash(${tmp} "cccb77be9609d2768ed80dd42cec54f77b1f1456" hash)
assert_equal(${hash} "cccb77be")
assert_contents_equal(${tmp}/cccb77be.hash cccb77be9609d2768ed80dd42cec54f77b1f1456)

# check that legacy hashs are recognized
file(MAKE_DIRECTORY "${tmp}/cccb77be9609d2768ed80dd42cec54f77b1f1457")
cpm_get_shortest_hash(${tmp} "cccb77be9609d2768ed80dd42cec54f77b1f1457" hash)
assert_equal(${hash} "cccb77be9609d2768ed80dd42cec54f77b1f1457")

# 1. The old file should still exist, and have the same content
assert_contents_equal(${tmp}/cccb.hash cccb77ae9609d2768ed80dd42cec54f77b1f1455)
assert_contents_equal(${tmp}/cccb77ae.hash cccb77ae9609d2768ed80dd42cec54f77b1f1456)
assert_contents_equal(${tmp}/cccb77ae9609.hash cccb77ae9609d2768ed80dd42cec54f77b1f1457)
assert_contents_equal(${tmp}/cccb77ae9608.hash cccb77ae9608d2768ed80dd42cec54f77b1f1455)
assert_contents_equal(${tmp}/cccb77be.hash cccb77be9609d2768ed80dd42cec54f77b1f1456)

# 1. Confirm idempotence: calling any of these function should produce the same hash as before (hash
#   lookups work correctly once the .hash files are created)

cpm_get_shortest_hash(${tmp} "cccb77ae9609d2768ed80dd42cec54f77b1f1455" hash)
assert_equal(${hash} "cccb")
assert_contents_equal(${tmp}/cccb.hash cccb77ae9609d2768ed80dd42cec54f77b1f1455)

cpm_get_shortest_hash(${tmp} "cccb77ae9609d2768ed80dd42cec54f77b1f1456" hash)
assert_equal(${hash} "cccb77ae")
assert_contents_equal(${tmp}/cccb77ae.hash cccb77ae9609d2768ed80dd42cec54f77b1f1456)

cpm_get_shortest_hash(${tmp} "cccb77ae9609d2768ed80dd42cec54f77b1f1457" hash)
assert_equal(${hash} "cccb77ae9609")
assert_contents_equal(${tmp}/cccb77ae9609.hash cccb77ae9609d2768ed80dd42cec54f77b1f1457)

cpm_get_shortest_hash(${tmp} "cccb77ae9608d2768ed80dd42cec54f77b1f1455" hash)
assert_equal(${hash} "cccb77ae9608")
assert_contents_equal(${tmp}/cccb77ae9608.hash cccb77ae9608d2768ed80dd42cec54f77b1f1455)

cpm_get_shortest_hash(${tmp} "cccb77be9609d2768ed80dd42cec54f77b1f1456" hash)
assert_equal(${hash} "cccb77be")
assert_contents_equal(${tmp}/cccb77be.hash cccb77be9609d2768ed80dd42cec54f77b1f1456)

# 1. Cleanup - remove the temporary directory that we created

file(REMOVE_RECURSE ${tmp})
