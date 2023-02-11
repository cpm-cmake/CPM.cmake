require_relative './lib'

class Parallelism < IntegrationTest
  def setup
    @cache_dir = File.join(cur_test_dir, 'cpmcache')
    ENV['CPM_SOURCE_CACHE'] = @cache_dir
  end

  def test_populate_cache_in_parallel
    4.times.map { |i|
      prj = make_project name: i.to_s, from_template: 'using-fibadder'
      prj.create_lists_from_default_template package: 'CPMAddPackage("gh:cpm-cmake/testpack-fibadder@1.0.0")'
      prj
    }.map { |prj|
      Thread.new do
        assert_success prj.configure
        assert_success prj.build
      end
    }.map(&:join)
  end
end
