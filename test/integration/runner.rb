require 'fileutils'
require 'open3'
require 'tmpdir'
require 'test/unit'

TestTmpDir = File.join(Dir.tmpdir, "cpm-itest-#{Time.now.strftime('%Y_%m_%d-%H_%M_%S')}")
raise "Test directory '#{TestTmpDir}' already exists" if File.exist?(TestTmpDir)

puts "Running CPM.cmake integration tests"
puts "Temp directory: '#{TestTmpDir}'"

CPMPath = File.expand_path('../../cmake/CPM.cmake', __dir__)
raise "Cannot file 'CPM.cmake' at '#{CPMPath}'" if !File.file?(CPMPath)

# Environment variables which are read by cpm
CPM_ENV = %w(
  CPM_USE_LOCAL_PACKAGES
  CPM_LOCAL_PACKAGES_ONLY
  CPM_DOWNLOAD_ALL
  CPM_DONT_UPDATE_MODULE_PATH
  CPM_DONT_CREATE_PACKAGE_LOCK
  CPM_INCLUDE_ALL_IN_PACKAGE_LOCK
  CPM_USE_NAMED_CACHE_DIRECTORIES
  CPM_SOURCE_CACHE
)

# Clear existing cpm-related env vars
CPM_ENV.each { ENV[_1] = nil }

class Project
  def initialize(dir)
    @dir = File.join(TestTmpDir, dir)
  end
end

# exit Test::Unit::AutoRunner::run(true, __dir__)

