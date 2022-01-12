require 'fileutils'
require 'open3'
require 'tmpdir'
require 'test/unit'

module TestLib
  TMP_DIR = File.expand_path(ENV['CPM_INTEGRATION_TEST_DIR'] || File.join(Dir.tmpdir, 'cpm-test', Time.now.strftime('%Y_%m_%d-%H_%M_%S')))
  CPM_PATH = File.expand_path('../../cmake/CPM.cmake', __dir__)

  TEMPLATES_DIR = File.expand_path('templates', __dir__)

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
  def self.clear_env
    CPM_ENV.each { ENV[_1] = nil }
  end
end

puts "Warning: test directory '#{TestLib::TMP_DIR}' already exists" if File.exist?(TestLib::TMP_DIR)
raise "Cannot find 'CPM.cmake' at '#{TestLib::CPM_PATH}'" if !File.file?(TestLib::CPM_PATH)

puts "Running CPM.cmake integration tests"
puts "Temp directory: '#{TestLib::TMP_DIR}'"

class Project
  def initialize(src_dir, build_dir)
    @src_dir = src_dir
    @build_dir = build_dir
  end

  def create_file(target_path, text)
    target_path = File.join(@src_dir, target_path)
    File.write target_path, text
  end

  def create_file_with(target_path, source_path, args)
    source_path = File.join(@src_dir, source_path)
    raise "#{source_path} doesn't exist" if !File.file?(source_path)

    # tweak args
    args[:cpm_path] = TestLib::CPM_PATH
    args[:packages] = [args[:package]] if args[:package] # if args contain package, create the array
    args[:packages] = args[:packages].join("\n") # join all packages

    src_text = File.read source_path
    create_file target_path, src_text % args
  end

  # common function to create ./CMakeLists.txt from ./lists.in.cmake
  def create_lists_with(args)
    create_file_with 'CMakeLists.txt', 'lists.in.cmake', args
  end

  CommandResult = Struct.new :out, :err, :status
  def configure(extra_args = '')
    CommandResult.new *Open3.capture3("cmake -S #{@src_dir} -B #{@build_dir} #{extra_args}")
  end

  class CMakeCacheEntry
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
  class CMakeCache
    def initialize(entries)
      @entries = entries
    end
    def self.from_dir(dir)
      entries = {}
      cur_desc = ''
      file = File.join(dir, 'CMakeCache.txt')
      return nil if !File.file?(file)
      File.readlines(file).each { |line|
        line.strip!
        next if line.empty?
        next if line.start_with? '#' # comment
        if line.start_with? '//'
          cur_desc += line[2..]
        else
          m = /(.+?)(-ADVANCED)?:([A-Z]+)=(.*)/.match(line)
          raise "Error parsing '#{line}' in #{file}" if !m
          entries[m[1]] = CMakeCacheEntry.new(m[4], m[3], !!m[2], cur_desc)
          cur_desc = ''
        end
      }
      CMakeCache.new entries
    end

    def [](key)
      e = @entries[key]
      return nil if !e
      e.val
    end

    def get_package_data(package)
      [
        self["CPM_PACKAGE_#{package}_VERSION"],
        self["CPM_PACKAGE_#{package}_SOURCE_DIR"],
        self["CPM_PACKAGE_#{package}_BINARY_DIR"],
      ]
    end
  end
  def read_cache
    CMakeCache.from_dir @build_dir
  end
end

class IntegrationTest < Test::Unit::TestCase
  def setup
    # Clear existing cpm-related env vars
    TestLib.clear_env
  end

  def make_project(template_dir = nil)
    test_name = local_name
    test_name = test_name[5..] if test_name.start_with?('test_')

    base = File.join(TestLib::TMP_DIR, self.class.name.downcase, test_name)
    src_dir = base + '-src'

    FileUtils.mkdir_p src_dir

    if template_dir
      template_dir = File.join(TestLib::TEMPLATES_DIR, template_dir)
      raise "#{template_dir} is not a directory" if !File.directory?(template_dir)
      FileUtils.copy_entry template_dir, src_dir
    end

    Project.new src_dir, base + '-build'
  end
end
