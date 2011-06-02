require 'helper'

module Journey
  class TestRoute < MiniTest::Unit::TestCase
    def test_initialize
      app      = Object.new
      path     = Path::Pattern.new '/:controller(/:action(/:id(.:format)))'
      defaults = Object.new
      route    = Route.new(app, path, {}, defaults)

      assert_equal app, route.app
      assert_equal path, route.path
      assert_equal defaults, route.extras
    end

    def test_ip_address
      path  = Path::Pattern.new '/messages/:id(.:format)'
      route = Route.new(nil, path, {:ip => '192.168.1.1'},
                        { :controller => 'foo', :action => 'bar' })
      assert_equal '192.168.1.1', route.ip
    end

    def test_default_ip
      path  = Path::Pattern.new '/messages/:id(.:format)'
      route = Route.new(nil, path, {},
                        { :controller => 'foo', :action => 'bar' })
      assert_equal(//, route.ip)
    end

    def test_format_empty
      path  = Path::Pattern.new '/messages/:id(.:format)'
      route = Route.new(nil, path, {},
                        { :controller => 'foo', :action => 'bar' })

      assert_equal '/messages', route.format({})
    end

    def test_connects_all_match
      path  = Path::Pattern.new '/:controller(/:action(/:id(.:format)))'
      route = Route.new(nil, path, {},
                        { :controller => 'foo', :action => 'bar' })

      assert_equal '/foo/bar/10', route.format({
        :controller => 'foo',
        :action     => 'bar',
        :id         => 10
      })
    end

    def test_score
      path = Path::Pattern.new "/page/:id(/:action)(.:format)"
      specific = Route.new nil, path, {}, {:controller=>"pages", :action=>"show"}

      path = Path::Pattern.new "/:controller(/:action(/:id))(.:format)"
      generic = Route.new nil, path, {}

      knowledge = {:id=>20, :controller=>"pages", :action=>"show"}

      routes = [specific, generic]

      refute_equal specific.score(knowledge), generic.score(knowledge)

      found = routes.sort_by { |r| r.score(knowledge) }.last

      assert_equal specific, found
    end
  end
end
