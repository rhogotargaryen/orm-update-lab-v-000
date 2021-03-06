require_relative "../config/environment.rb"

class Student
  
  attr_accessor :name, :grade, :id
  
  def initialize(name, grade, id =  nil)
    @name = name
    @grade = grade
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
      )
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students
    SQL
    
    DB[:conn].execute(sql)
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  
  def self.create(name, grade)
    nu_stud = self.new(name, grade)
    nu_stud.save
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    self.new(name, grade, id)
  end
  
  def self.all
    sql = <<-SQL
    SELECT * FROM students
    SQL
    
    DB[:conn].execute(sql).map {|x| Student.new_from_db(x)}
  end
  
  def self.find_by_name(name)
    self.all.each {|x| return x if x.name == name}
  end
  
end
