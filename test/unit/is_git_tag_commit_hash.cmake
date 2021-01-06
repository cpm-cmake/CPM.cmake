cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(${CPM_PATH}/CPM.cmake)
include(${CPM_PATH}/testing.cmake)

cpm_is_git_tag_commit_hash("v1.2.3" RESULT)
assert_equal("0" ${RESULT})

cpm_is_git_tag_commit_hash("asio-1-12-1" RESULT)
assert_equal("0" ${RESULT})

cpm_is_git_tag_commit_hash("513039e3cba83284cec71287fd829865b9f423bc" RESULT)
assert_equal("1" ${RESULT})

cpm_is_git_tag_commit_hash("513039E3CBA83284CEC71287FD829865B9F423BC" RESULT)
assert_equal("1" ${RESULT})

cpm_is_git_tag_commit_hash("513039E" RESULT)
assert_equal("1" ${RESULT})

cpm_is_git_tag_commit_hash("513039E3CBA8" RESULT)
assert_equal("1" ${RESULT})
