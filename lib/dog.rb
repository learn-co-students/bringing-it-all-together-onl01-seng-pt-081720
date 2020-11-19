class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(dog_hash)
        @name = dog_hash[:name]
        @breed = dog_hash[:breed]

        if dog_hash[:breed] != nil
            @id = dog_hash[:id]
        else
            @id = nil
        end
        
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        new_dog = self.new(attributes)
        new_dog.save
    end

    def self.new_from_db(array_values)
        dog_hash = {}
        dog_hash[:id] = array_values[0]
        dog_hash[:name] = array_values[1]
        dog_hash[:breed] = array_values[2]
        new_dog = self.new(dog_hash)
    end

    def self.find_by_id(id_to_find)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL
        dog_from_db = DB[:conn].execute(sql, id_to_find)[0]
        self.new_from_db(dog_from_db)
    end

    def self.find_or_create_by(values)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        dog_from_db = DB[:conn].execute(sql, values[:name], values[:breed])
        if dog_from_db.length > 0
            array_dog_values = dog_from_db[0]
            self.new_from_db(array_dog_values)
        else
            new_dog = self.new(values)
            new_dog.save
            new_dog
        end
    end

    def self.find_by_name(name_to_find)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
        dog_from_db = DB[:conn].execute(sql, name_to_find)[0]
        self.new_from_db(dog_from_db)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
    end

end