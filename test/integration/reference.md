# Integration Test Framework Reference

## `TestLib`

A module for the framework. Provides global data and functionality. For ease of use the utility classes are *not* in this module.

Provides:

* `TMP_DIR` - the temporary directory for the current test run
* `CPM_PATH` - path to CPM.cmake. The thing that is being tested
* `TEMPLATES_DIR` - path to integration test templates
* `CPM_ENV` - an array of the names of all environment variables, which CPM.cmake may read
* `.clear_env` - a function to clear all aforementioned environment variables

## `Project`

A helper class to manage a CMake project.

Provides:

* `#initialize(src_dir, bin_dir)` - create a project with a given source and binary directory
* `#src_dir`, `#bin_dir` - get project directories
* `#create_file(target_path, text, args = {})` - create a file in the project's source directory with a given test. The `args` hash is used to interpolate markup in the text string.
    * Will set `:cpm_path` in `args` to `TestLib::CPM_PATH` if not already present.
    * If `:package` is present it will be added to the array `:packages`
    * Will convert `:packages` form an array to a string
* `#create_file_from_template(target_path, source_path, args = {})` - create a file in the project source directory, based on another file in the project source directory. The contents of the file at `source_path` will be read and used in `create_file`
* `#create_lists_from_default_template(args = {})` - same as `create_file_from_template('CMakeLists.txt', 'lists.in.cmake', args)`
* `::CommandResult` - a struct of:
    * `out` - the standard output from a command execution
    * `err` - the standard error output from the execution
    * `status` - the [`Process::Status`](https://ruby-doc.org/core-2.7.0/Process/Status.html) of the execution
* `#configure(extra_args = '') => CommandResult` - configure the project with optional extra args to CMake
* `#build(extra_args = '') => CommandResult` - build the project with optional extra args to CMake
* `::CMakeCache` - a helper class with the contents of a CMakeCache.txt. Provides:
    * `::Entry` - a CMake cache entry of:
        * `val` - the value as string
        * `type` - the type as string
        * `advanced?` - whether the entry is an advanced option
        * `desc` - the description of the entry (can be an empty string)
    * `::Package` - the CMake cache for a CPM.cmake package. A struct of:
        * `ver` - the version as string
        * `src_dir`, `bin_dir` - the source and binary directories of the package
    * `.from_dir(dir)` - create an instance of `CMakeCache` from `<dir>/CMakeLists.txt`
    * `#initialize(entries)` - create a cache from a hash of entries by name. Will populate packages.
    * `#entries => {String => Entry}` - the entries of the cache
    * `#packages => {String => Package}` - CPM.cmake packages by name found in the cache
    * `#[](key) => String` - an entry value from an entry name. Created because the value is expected to be needed much more frequently than the entire entry data. To get a full entry use `cache.entries['name']`.
* `read_cache => CMakeCache` - reads the CMake cache in the binary directory of the project and returns it as a `CMakeCache` instance

## `IntegrationTest`

The class which must be a parent of all integration test case classes. It itself extends `Test::Unit::TestCase` with:

### Assertions

* `assert_success(res)` - assert that an instance of `Project::CommandResult` is a success
* `assert_same_path(a, b)` - assert that two strings represent the same path. For example on Windows `c:\foo` and `C:\Foo` do.

### Utils

* `cur_test_dir` - the directory of the current test case. A subdirectory of `TestLib::TMP_DIR`
* `make_project(name: nil, from_template: nil)` - create a project from a test method. Will create the project's source and binary directories as subdirectories of `cur_test_dir`.
    * Optionally provide a name which will be concatenated to the project directory. This allows creating multiple projects in a test
    * Optionally work with a template, in which case it will copy the contents of the template directory (one from `templates`) in the project's source directory.

