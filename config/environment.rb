require 'sqlite3'
require 'pry'
require_relative '../lib/dog'

DB = {:conn => SQLite3::Database.new("db/dogs.db")}

dog_1 = Dog.new(id: 3, name:'Nala', breed: "Golden")
dog_2 = Dog.new(id: 4, name:'Pepper', breed: "Toller")


#binding.pry
0