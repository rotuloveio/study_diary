class Categoria
  attr_accessor :name

  def initialize(name:)
    @name = name
  end

  CATEGORIES = [
    new(name: 'Ruby'),
    new(name: 'Rails'),
    new(name: 'JavaScript')
  ].freeze

  def self.all
    CATEGORIES
  end

  def to_s
    name
  end
end
