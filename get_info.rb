require 'stoplight'
require 'rest-client'
require 'pry'
require 'redis'

COLORS = [
        GREEN = Stoplight::Color::GREEN,
        YELLOW = Stoplight::Color::YELLOW,
        RED = Stoplight::Color::RED
      ].freeze

def light_info(light)
  l = Stoplight::Light.new(light) {}
  color = l.color
  failures, state = l.data_store.get_all(l)

  {
    name: light,
    color: color,
    failures: failures,
    locked: locked?(state)
  }
end

def locked?(state)
  [Stoplight::State::LOCKED_GREEN,
   Stoplight::State::LOCKED_RED]
    .include?(state)
end

def light_sort_key(light)
  [-COLORS.index(light[:color]),
   light[:name]]
end

redis = Redis.new
datastore = Stoplight::DataStore::Redis.new(redis)
Stoplight::Light.default_data_store = datastore

ds = Stoplight::Light.default_data_store

lights = ds
          .names
          .map { |name| light_info(name) }
          .sort_by { |light| light_sort_key(light) }
puts lights
