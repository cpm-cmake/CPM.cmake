require 'fileutils'
require 'open3'

CPMPath = File.expand_path('../../cmake/CPM.cmake')
raise "Cannot file 'CPM.cmake' at '#{CPMPath}'" if !File.file?(CPMPath)

CommonHeader = <<~CMAKE
  cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
  include("#{CPMPath}")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
CMAKE

TestDir = File.expand_path("./tmp/#{Time.now.strftime('%Y_%m_%d-%H_%M_%S')}")
raise "Test directory '#{TestDir}' already exists" if File.exist?(TestDir)

class CMakeListsBuilder
  def initialize
    @contents = ''
  end
  def literal(lit)
    @contents += lit + "\n";
    self
  end
  def package(pack)
    literal "CPMAddPackage(#{pack})"
  end
  def exe(exe, sources)
    @contents += "add_executable(#{exe}\n"
    @contents += sources.map { |src|
      '  ' + if src['/']
        src
      else
        File.expand_path("./#{src}")
      end
    }.join("\n")
    @contents += "\n)\n"
    self
  end
  def link_libs(target, libs)
    literal "target_link_libraries(#{target} #{libs})\n"
  end
  def to_s
    @contents
  end
end

class Project
  def initialize(name)
    @name = name
    @dir = File.join(TestDir, name)

    FileUtils.mkdir_p(File.join(TestDir, name))
  end

  def build_cmake_lists(opts = {}, &block)
    builder = CMakeListsBuilder.new
    if !opts[:no_default_header]
      builder.literal(CommonHeader)
      builder.literal("project(#{@name})")
    end
    text = builder.instance_eval &block

    File.write(File.join(@dir, 'CMakeLists.txt'), text)
  end

  def configure(args = '')
    our, err, s = Open3.capture3("cmake . #{args}", chdir: @dir)
  end
end

@cur_file = ''
@tests = {}
def add_test(name, func)
  raise "#{@cur_file}: Test #{name} is already defined from another file" if @tests[name]
  @tests[name] = func
end

Dir['tests/*.rb'].sort.each do |file|
  @cur_file = file
  load './' + file
end

# sort alphabetically
sorted_tests = @tests.to_a.sort {|a, b| a[0] <=> b[0] }

sorted_tests.each do |name, func|
  proj = Project.new(name)
  func.(proj)
end
