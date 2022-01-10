require 'fileutils'
require 'open3'
require 'tmpdir'
require 'test/unit'

TestTmpDir = File.join(Dir.tmpdir, "cpm-itest-#{Time.now.strftime('%Y_%m_%d-%H_%M_%S')}")
raise "Test directory '#{TestTmpDir}' already exists" if File.exist?(TestTmpDir)

puts "Running CPM.cmake integration tests"
puts "Temp directory: '#{TestTmpDir}'"

CPMPath = File.expand_path('../../cmake/CPM.cmake', __dir__)
raise "Cannot find 'CPM.cmake' at '#{CPMPath}'" if !File.file?(CPMPath)

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
  def initialize(dir, name)
    @name = name
    d = File.join(TestTmpDir, dir)
    @src_dir = d + '-src'
    @build_dir = d + '-build'
    p @src_dir
    FileUtils.mkdir_p [@src_dir, @build_dir]
  end

  class CMakeCacheValue
    def initialize(val, type, advanced, desc)
      @val = val
      @type = type
      @advanced = advanced
      @desc = desc
    end
    attr :val, :type, :advanced, :desc
    alias_method :advanced?, :advanced
    def inspect
      "(#{val.inspect} #{type}" + (advanced? ? ' ADVANCED)' : ')')
    end
  end
  def read_cache
    vars = {}
    cur_desc = ''
    file = File.join(@build_dir, 'CMakeCache.txt')
    File.readlines(file).each { |line|
      line.strip!
      next if line.empty?
      next if line.start_with? '#' # comment
      if line.start_with? '//'
        cur_desc += line[2..]
      else
        m = /(.+?)(-ADVANCED)?:([A-Z]+)=(.*)/.match(line)
        raise "Error parsing '#{line}' in #{file}" if !m
        vars[m[1]] = CMakeCacheValue.new(m[4], m[3], !!m[2], cur_desc)
        cur_desc = ''
      end
    }
    vars
  end
end

class IntegrationTest < Test::Unit::TestCase
  def make_project(name = nil)
    test_name = local_name
    test_name = test_name[5..] if test_name.start_with?('test_')
    name = test_name if !name
    Project.new "#{self.class.name.downcase}-#{test_name}", name
  end
end
