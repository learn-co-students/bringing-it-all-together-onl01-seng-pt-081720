require  'pry'

class Dog 
  attr_accessor :name, :breed
  attr_reader :id 
  
  def initialize(id: nil, name: , breed: )
    @id = id 
    @name = name 
    @breed = breed 
  end
  
  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT, 
      breed TEXT);
    SQL
  
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL 
     DROP TABLE dogs
    SQL
  
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM dogs
      WHERE name = ?
    SQL
  
     result = DB[:conn].execute(sql, name)[0]
     Dog.new(id: result[0], name: result[1], breed: result[2])
  end
  
  def save
    if !!self.id
      self.update
    else  
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
    
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
     self
   end
   
  def self.create(hash) 
    new_dog = self.new(hash)
    new_dog.save
    new_dog
  end
  
  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id)[0]

    Dog.new(id: result[0], name: result[1], breed: result[2])
  end
  
  def self.find_or_create_by(hash)
    sql = <<-SQL 
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    data = DB[:conn].execute(sql, hash[:name], hash[:breed])

    if data == []
      self.create(hash)
    else
      self.find_by_id(data[0][0])
    end
  end
    
  def update
    sql = <<-SQL 
      UPDATE dogs SET name = ?, breed = ?  
      WHERE id = ?
    SQL
  
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self
  end
end