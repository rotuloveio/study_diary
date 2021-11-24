require 'sqlite3'
require_relative 'Categoria'

class Tarefa
  attr_accessor :category, :title, :description

  def initialize(category:, title:, description:)
    @category = Categoria.new(name: category)
    @title = title
    @description = description
  end

  def self.all
    db = SQLite3::Database.open 'db/database.db'
    db.results_as_hash = true
    tasks = db.execute 'SELECT category, title, descr FROM tasks'
    db.close

    tasks.map do |task|
      new(category: task['category'], title: task['title'], description: task['descr'])
    end
  end

  def self.done
    db = SQLite3::Database.open 'db/database.db'
    db.results_as_hash = true
    tasks = db.execute 'SELECT category, title, descr FROM done'
    db.close

    tasks.map do |task|
      new(category: task['category'], title: task['title'], description: task['descr'])
    end
  end

  def self.save_to_db(task)
    db = SQLite3::Database.open 'db/database.db'
    db.execute "INSERT INTO tasks VALUES('#{task.category.name}', '#{task.title}', '#{task.description}')"
    db.close

    self
  end

  def self.find_by_keyword(keyword)
    db = SQLite3::Database.open 'db/database.db'
    db.results_as_hash = true
    tasks = db.execute "SELECT title, category, descr FROM tasks where descr LIKE '%#{keyword}%' OR title LIKE '%#{keyword}%'"
    db.close

    tasks.map do |task|
      new(category: task['category'], title: task['title'], description: task['descr'])
    end
  end

  def self.find_by_category(category)
    db = SQLite3::Database.open 'db/database.db'
    db.results_as_hash = true
    tasks = db.execute "SELECT title, category, descr FROM tasks where category LIKE '#{category}'"
    db.close

    tasks.map do |task|
      new(category: task['category'], title: task['title'], description: task['descr'])
    end
  end

  def self.delete_or_done(task, done)
    db = SQLite3::Database.open 'db/database.db'
    db.execute "DELETE FROM tasks WHERE title LIKE '#{task.title}' AND category LIKE '#{task.category.name}'"
    db.execute "INSERT INTO done VALUES ('#{task.category.name}', '#{task.title}', '#{task.description}')" if done
    db.close
  end

  def to_s
    "#{title}: #{description}"
  end
end
