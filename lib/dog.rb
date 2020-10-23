class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
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
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(dog_hash)
        new_dog = self.new(dog_hash)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL
        self.new_from_db(DB[:conn].execute(sql, id)[0])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs 
            WHERE name = ? AND breed = ?
        SQL
        dogs = DB[:conn].execute(sql, name, breed)
        if !dogs.empty?
            dog_array = dogs[0]
            dog = self.new_from_db(dog_array)
        else
            dog = self.new(name: name, breed: breed)
            dog.save
        end
    dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, name)[0]
        self.new_from_db(dog)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
    end
end