class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
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
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs ")[0][0]
    end
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    attributes = (DB[:conn].execute(sql, id)[0])
    self.new_from_db(attributes)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    attributes = (DB[:conn].execute(sql, name)[0])
    self.new_from_db(attributes)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)[0]
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(dog)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    search_result = DB[:conn].execute(sql, dog[:name], dog[:breed])[0]
    if search_result == nil
      self.create(dog)
    else
      self.new_from_db(search_result)
    end
  end
end