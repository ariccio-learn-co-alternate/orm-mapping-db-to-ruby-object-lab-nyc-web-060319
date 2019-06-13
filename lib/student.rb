require "pry"

def student_from_row(row)
  new_student = Student.new
  new_student.init(row[0], row[1], row[2])
  new_student
end

class Student
  attr_accessor :id, :name, :grade

  def init(id, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    # sql =<<-SQL
    #   SELECT id, name, grade FROM students WHERE students.id = ? AND students.name = ? AND students.grade = ?
    # SQL
    # result = DB[:conn].execute(sql, [row[0], row[1], row[2]])
    # binding.pry
    new_student = Student.new
    new_student.init(row[0], row[1], row[2])
    new_student
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql =<<-SQL
      SELECT id, name, grade FROM students WHERE name is ?
    SQL
    result = DB[:conn].execute(sql, name)
    new_student = Student.new
    #binding.pry
    new_student.init(result[0][0], result[0][1], result[0][2])
    new_student
  end

  def self.all_students_in_grade_9
    self.all_students_in_grade_X(9)
  end

  def self.all_students_in_grade_X(x)
    sql =<<-SQL
    SELECT id, name, grade FROM students WHERE grade is ?
    SQL
    result = DB[:conn].execute(sql, [x])
    result.map! do |student_result|
      student_from_row(student_result)
    end
  end
  
  def self.students_below_12th_grade
    sql =<<-SQL
    SELECT id, name, grade FROM students WHERE grade is NOT 12
    SQL
    result = DB[:conn].execute(sql)
    result.map! do |student_result|
      student_from_row(student_result)
    end
  end

  def self.all
    sql =<<-SQL
      SELECT * FROM students
    SQL
    result = DB[:conn].execute(sql)
    #binding.pry
    result.map! do |student_result|
      student_from_row(student_result)
    end
  end

  def self.first_X_students_in_grade_10(x)
    sql =<<-SQL
      SELECT * FROM students WHERE grade is 10 LIMIT ?
    SQL
    result = DB[:conn].execute(sql, [x])
    result.map! do |student_result|
      student_from_row(student_result)
    end
  end

  def self.first_student_in_grade_10
    self.first_X_students_in_grade_10(1)[0]
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, [self.name, self.grade])
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
    #binding.pry
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
end
