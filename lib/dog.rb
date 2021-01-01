class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: id, name: name, breed: breed)
        @id = id
        @name = name
        @breed = breed
    end

    # Creates the dogs table in the database
    def self.create_table

        # SQL query string that creates a table in the database if it doesn't exist.
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        # Executes that string
        DB[:conn].execute(sql)
    end

    # Drops the dogs table from the database
    def self.drop_table

        # SQL query that erases the table from the database if it exists
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL

        # Executes that string
        DB[:conn].execute(sql)
    end

    # Returns an instance of the dog class 
    # Saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    def save

        # SQL query string that inserts a new row of data corresponding to the instance variable the method is called on
        sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?,?)
        SQL

        # Executes the SQL query
        DB[:conn].execute(sql, self.name, self.breed)

        # Sets the dogs id attribute
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        # Returns the instance of the dog class 
        self

    end

    # Takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database 
    # Returns a new dog object 
    def self.create(name: name, breed: breed)

        # Creates a new dog object
        dog = self.new(name: name, breed: breed)

        # Saves the dog to the database
        dog.save

        # Returns the new dog object
        dog
    end

    # Creates an instance with corresponding attribute values 
    def self.new_from_db(row)

        # Creates a new dog instance
        new_dog = Dog.new

        # Sets the attributes of the instance equal to the elements of the data passed in via row
        new_dog.id = row[0]
        new_dog.name = row[1]
        new_dog.breed = row[2]

        # Returns the dog instance
        new_dog

    end

    # Returns a new dog object by id
    def self.find_by_id(id)

        # SQL query that finds dog associated with given id
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        # Sets an array containing the dog data associated with the given id equal to "result"
        result = DB[:conn].execute(sql, id)[0]

        # Calls on .new_from_db to create a new instance of a dog in Ruby from the SQL data
        self.new_from_db(result)

    end

    # Creates an instance of a dog if it does not already exist 
    # When two dogs have the same name and different breed, it returns the correct dog 
    # When creating a new dog with the same name as persisted dogs, it returns the correct dog 
    def self.find_or_create_by(name: name, breed: breed)

        # Sets dog equal to array of arrays of dogs whose name and breed match inputs
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

        # If there are dogs whose name and breed match then create a dog instance with those attributes
        if !dog.empty?
            dog_data = dog[0]
            new_dog = Dog.new
            new_dog.id = dog_data[0]
            new_dog.name = dog_data[1]
            new_dog.breed = dog_data[2]
        
        # If there are no matching dogs then it creates that dog
        else
            new_dog = self.create(name: name, breed: breed)
        end
        new_dog
    end

    # Returns an instance of dog that matches the name from the DB
    def self.find_by_name(name)

        # SQL query that finds dog associated with given id
        sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
        SQL

        # Sets an array containing the dog data associated with the given id equal to "result"
        result = DB[:conn].execute(sql, name)[0]

        # Calls on .new_from_db to create a new instance of a dog in Ruby from the SQL data
        self.new_from_db(result)

    end

    # Updates the record associated with a given instance
    def update

        # Finds id in SQL data that matches associated instance of Dog then updates his/her name and breed.
        sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
        
        # Executes the SQL query.
        DB[:conn].execute(sql, self.name, self.breed, self.id)

    end

end