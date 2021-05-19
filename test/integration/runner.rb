require 'fileutils'

CPMPath = File.expand_path('../../cmake/CPM.cmake')
raise "Cannot file 'CPM.cmake' at '#{CPMPath}'" if !File.file?(CPMPath)

CommonHeader = <<~CMAKE
  cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
  include("#{CPMPath}")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
CMAKE

TestDir = File.expand_path("./tmp/#{Time.now.strftime('%Y_%m_%d-%H_%M_%S')}")
raise "Test directory '#{TestDir}' already exists" if File.exist?(TestDir)

class Project
  def initialize(name)
    @name = name
    @dir = File.join(TestDir, name)

    @lists = CommonHeader + "project(#{name})\n"

    FileUtils.mkdir_p(File.join(TestDir, name))
  end

  def set_body(body)
    @lists += "\n" + body + "\n"
  end

  def configure()
    File.write(File.join(@dir, 'CMakeLists.txt'), @lists)
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
