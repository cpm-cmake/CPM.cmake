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

# Clean all CPM-related env vars
TestLib.clear_env

class Project
  def initialize(src_dir, bin_dir)
    @src_dir = src_dir
    @bin_dir = bin_dir
  end

  attr :src_dir, :bin_dir

  def create_file(target_path, text, args = {})
    target_path = File.join(@src_dir, target_path)

    # tweak args
    args[:cpm_path] = TestLib::CPM_PATH if !args[:cpm_path]
    args[:packages] = [args[:package]] if args[:package] # if args contain package, create the array
    args[:packages] = args[:packages].join("\n") if args[:packages] # join all packages if any

    File.write target_path, text % args
  end

  def create_file_from_template(target_path, source_path, args = {})
    source_path = File.join(@src_dir, source_path)
    raise "#{source_path} doesn't exist" if !File.file?(source_path)
    src_text = File.read source_path
    create_file target_path, src_text, args
  end

  # common function to create ./CMakeLists.txt from ./lists.in.cmake
  def create_lists_from_default_template(args = {})
    create_file_from_template 'CMakeLists.txt', 'lists.in.cmake', args
  end

  CommandResult = Struct.new :out, :err, :status
  def configure(extra_args = '')
    CommandResult.new *Open3.capture3("cmake -S #{@src_dir} -B #{@bin_dir} #{extra_args}")
  end
  def build(extra_args = '')
    CommandResult.new *Open3.capture3("cmake --build #{@bin_dir} #{extra_args}")
  end

  class CMakeCache
    class Entry
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

    Package = Struct.new(:ver, :src_dir, :bin_dir)

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
          entries[m[1]] = Entry.new(m[4], m[3], !!m[2], cur_desc)
          cur_desc = ''
        end
      }
      CMakeCache.new entries
    end

    def initialize(entries)
      @entries = entries

      package_list = self['CPM_PACKAGES']
      @packages = if package_list
        # collect package data
        @packages = package_list.split(';').map { |name|
          [name, Package.new(
            self["CPM_PACKAGE_#{name}_VERSION"],
            self["CPM_PACKAGE_#{name}_SOURCE_DIR"],
            self["CPM_PACKAGE_#{name}_BINARY_DIR"]
          )]
        }.to_h
      else
        {}
      end
    end

    attr :entries, :packages

    def [](key)
      e = @entries[key]
      return nil if !e
      e.val
    end
  end
  def read_cache
    CMakeCache.from_dir @bin_dir
  end
end

class IntegrationTest < Test::Unit::TestCase
  self.test_order = :defined # run tests in order of definition (as opposed to alphabetical)

  def cleanup
    # Clear cpm-related env vars which may have been set by the test
    TestLib.clear_env
  end

  # extra assertions

  def assert_success(res)
    msg = build_message(nil, "command status was expected to be a success, but failed with code <?> and STDERR:\n\n#{res.err}", res.status.to_i)
    assert_block(msg) { res.status.success? }
  end

  def assert_failure(res)
    msg = build_message(nil, "command status was expected to be a failure, but succeeded")
    assert_block(msg) { !res.status.success? }
  end

  def assert_same_path(a, b)
    msg = build_message(nil, "<?> expected but was\n<?>", a, b)
    assert_block(msg) { File.identical? a, b }
  end

  # utils
  class << self
    def startup
      @@test_dir = File.join(TestLib::TMP_DIR, self.name.
        # to-underscore conversion from Rails
        gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      )
    end
  end

  def cur_test_dir
    @@test_dir
  end

  def make_project(name: nil, from_template: nil)
    test_name = local_name
    test_name = test_name[5..] if test_name.start_with?('test_')

    base = File.join(cur_test_dir, test_name)
    base += "-#{name}" if name
    src_dir = base + '-src'

    FileUtils.mkdir_p src_dir

    if from_template
      from_template = File.join(TestLib::TEMPLATES_DIR, from_template)
      raise "#{from_template} is not a directory" if !File.directory?(from_template)
      FileUtils.copy_entry from_template, src_dir
    end

    Project.new src_dir, base + '-bin'
  end
end
