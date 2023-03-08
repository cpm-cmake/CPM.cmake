require_relative './lib'

# Tests of cpm caches and vars when no packages are used

class Basics < IntegrationTest
  # Test cpm caches with no cpm-related env vars
  def test_cpm_default
    prj = make_project from_template: 'no-deps'
    prj.create_lists_from_default_template
    assert_success prj.configure

    @cache = prj.read_cache

    assert_empty @cache.packages

    assert_same_path TestLib::CPM_PATH, check_and_get('CPM_FILE')
    assert_same_path File.dirname(TestLib::CPM_PATH), check_and_get('CPM_DIRECTORY')

    assert_equal 'OFF', check_and_get('CPM_DRY_RUN')
    assert_equal 'CPM:', check_and_get('CPM_INDENT')
    assert_equal '1.0.0-development-version', check_and_get('CPM_VERSION')

    assert_equal 'OFF', check_and_get('CPM_SOURCE_CACHE', 'PATH')
    assert_equal 'OFF', check_and_get('CPM_DOWNLOAD_ALL', 'BOOL')
    assert_equal 'OFF', check_and_get('CPM_LOCAL_PACKAGES_ONLY', 'BOOL')
    assert_equal 'OFF', check_and_get('CPM_USE_LOCAL_PACKAGES', 'BOOL')
    assert_equal 'OFF', check_and_get('CPM_USE_NAMED_CACHE_DIRECTORIES', 'BOOL')

    assert_equal 'OFF', check_and_get('CPM_DONT_CREATE_PACKAGE_LOCK', 'BOOL')
    assert_equal 'OFF', check_and_get('CPM_INCLUDE_ALL_IN_PACKAGE_LOCK', 'BOOL')
    assert_same_path File.join(prj.bin_dir, 'cpm-package-lock.cmake'), check_and_get('CPM_PACKAGE_LOCK_FILE')

    assert_equal 'OFF', check_and_get('CPM_DONT_UPDATE_MODULE_PATH', 'BOOL')
    assert_same_path File.join(prj.bin_dir, 'CPM_modules'), check_and_get('CPM_MODULE_PATH')
  end

  # Test when env CPM_SOURCE_CACHE is set
  def test_env_cpm_source_cache
    ENV['CPM_SOURCE_CACHE'] = cur_test_dir

    prj = make_project from_template: 'no-deps'
    prj.create_lists_from_default_template
    assert_success prj.configure

    @cache = prj.read_cache

    assert_equal cur_test_dir, check_and_get('CPM_SOURCE_CACHE', 'PATH')
  end

  def check_and_get(key, type = 'INTERNAL')
    e = @cache.entries[key]
    assert_not_nil e, key
    assert_equal type, e.type, key
    e.val
  end
end
