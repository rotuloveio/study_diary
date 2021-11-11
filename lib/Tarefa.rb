require 'sqlite3'

class Tarefa
  attr_accessor :category, :title, :description

  def initialize(category:, title:, description:)
    @category = category
    @title = title
    @description = description
  end

  def self.all
    db = SQLite3::Database.open 'db/database.db'
    db.results_as_hash = true
    tasks = db.execute 'SELECT category, title, descr FROM tasks'
    db.close

    tasks.map do |title|
      new(category: title['category'], title: title['title'], description: title['descr'])
    end
  end

  def self.save_to_db(category, title, description)
    db = SQLite3::Database.open 'db/database.db'
    db.execute "INSERT INTO tasks VALUES('#{category}', '#{title}', '#{description}')"
    db.close

    self
  end

  def self.delete_by_name(title)
    db = SQLite3::Database.open 'db/database.db'
    db.execute "DELETE FROM tasks WHERE title LIKE '#{title}'"
    db.close
  end

  def self.find_by_title(title)
    db = SQLite3::Database.open 'db/database.db'
    db.results_as_hash = true
    tasks = db.execute "SELECT title, category, descr FROM tasks where descr LIKE '%#{title}%' OR title LIKE '%#{title}%'"
    db.close

    tasks.map do |task|
      new(category: task['category'], title: task['title'], description: task['descr'])
    end
  end

  def self.find_by_category(category)
    db = SQLite3::Database.open 'db/database.db'
    db.results_as_hash = true
    tasks = db.execute "SELECT title, category FROM tasks where category LIKE '#{category}'"
    db.close

    tasks.map do |task|
      new(category: task['category'], title: task['title'], description: task['descr'])
    end
  end
end
