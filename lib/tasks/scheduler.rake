namespace :cache do

  desc 'Caches the root action of this app'
  task :root => :environment do
    cache_path('/', 'index')
  end

  desc 'Caches the "best" action of this app'
  task :best => :environment do
    cache_path('/best', 'best')
  end

  def cache_path(path, name)
    cache = Dalli::Client.new

    # The app created below doesn't know its url. So, the cache creates one for example.com
    # Clear it out so we don't end up putting the example.com cache back in the cache
    cache.set("views/www.example.com/#{ name }", nil)

    app = ActionDispatch::Integration::Session.new(Rails.application)
    app.get path
    cache.set("views/top250instant.herokuapp.com/#{ name }", app.response.body, 172800)
  end

end

namespace :imdb_top_250 do

  desc 'Fetch IMDB top 250'
  task :fetch => :environment do
    IMDB.top_250.each { |movie_attributes| Movie.find_or_create_by_imdb_id(movie_attributes) }
  end

end

namespace :netflix do

  desc 'Fills in movie that do not have netflix data'
  task :fill => :environment do
    Movie.where(netflix_instant: nil).each { |movie| movie.fill_from_netflix }
  end

end