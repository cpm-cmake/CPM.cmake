require_relative './lib'

# Tests with source cache

class Parallelism < IntegrationTest
  def setup
    @cache_dir = File.join(cur_test_dir, 'cpmcache')
    ENV['CPM_SOURCE_CACHE'] = @cache_dir
  end

  def test_populate_cache_in_parallel

    [*1..4]
      .map{ |i|
        prj = make_project 'using-fibadder'
        prj.create_lists_from_default_template package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.0.0")'
        prj
      }
      .map{ |prj| Thread.new do 
        assert_success prj.configure 
        assert_success prj.build
      end }
      .map { |t| t.join }

  end

end
