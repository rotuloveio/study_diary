require_relative 'Tarefa'

def options_menu
  options = <<~OPTIONS
    Cadastrar novo item de estudo
    Ver itens cadastrados
    Buscar item de estudo
    Busca por categoria
    Excluir um item
    Sair
  OPTIONS

  options.split("\n")
end

def categories_menu
  categories = <<~CATEGORIES
    Ruby
    Rails
    Java Script
  CATEGORIES

  categories.split("\n")
end

def clear
  puts(`clear`)
end

def menu
  clear
  puts('DIÁRIO DE TAREFAS')
  @itens = Tarefa.all

  options_list = options_menu
  options_list.each_with_index do |text, index|
    puts "[#{ index + 1 }] #{ text }"
  end
  print('Sua opção: ')

  valid_options = (1..options_list.size).to_a
  input = gets.chomp.to_i
  until valid_options.include?(input)
    puts('Opção inválida!')
    options_list.each_with_index do |text, index|
      puts("[#{index + 1}] #{text}")
    end
    print('Sua opção: ')
    input = gets.chomp.to_i
  end
  @option = input
end

def create_item
  clear
  puts('Cadastrar novo item de estudo: ')
  print('Digite o nome do item de estudo: ')
  name = gets.chomp

  categories_list = categories_menu
  categories_list.each_with_index do |text, index|
    puts "[#{index + 1}] - #{text}"
  end

  valid_categories = (1..categories_list.size).to_a

  print('Defina a categoria: ')
  input = gets.chomp.to_i

  until valid_categories.include?(input)
    puts('Categoria inválida!')
    categories_list.each_with_index do |text, index|
      puts("[*#{index + 1}] - #{text}")
    end
    input = gets.chomp.to_i
  end

  category = input

  print('Escreva a descrição do item: ')
  description = gets.chomp

  Tarefa.save_to_db(category, name, description)
end

def list(itens)
  itens.sort_by!(&:category)
  categories_list = categories_menu

  categories_list.each_with_index do |category, index|
    if itens.map{|item| item.category.to_i}.uniq.include?(index + 1)
      puts("==== ##{index + 1} - #{category} ====")
      itens.each_with_index do |item, item_index|
        if item.category.to_i == index + 1
          puts("#{item_index + 1} - #{item.title}: #{item.description}")
        end
      end
      puts("\n")
    end
  end
  puts '__________________________________'
end
  
def search_by_keyword
  clear

  print('Digite o termo desejado: ')
  key = gets.chomp.downcase

  filtered_itens = Tarefa.find_by_title(key)

  if filtered_itens.length.zero?
    puts('Nenhum item encontrado.')
    puts('__________________________________')
  else
    puts "#{filtered_itens.length} iten(s) encontrado(s):\n\n"
    list(filtered_itens)
  end
end

def search_by_category
  clear
  puts('Busca por categoria:')
  categorys_list = categories_menu
  categorys_list.each_with_index do |text, index|
    puts("##{ index + 1 } - #{ text }")
  end
  print('Digite a categoria desejada: ')
  category = gets.chomp

  filtered_itens = Tarefa.find_by_category(category)

  if filtered_itens.length.zero?
    puts('Nenhum item encontrado.')
    puts('__________________________________')
  else
    puts("#{filtered_itens.length} iten(s) encontrado(s):\n\n")
    list(filtered_itens)
  end
end

def delete
  clear
  puts('Excluir um item')
  list(@itens)
  print('Escolha a categoria: ')
  categories_list = categories_menu

  valid_categories = (1..categories_list.size).to_a

  category = gets.chomp.to_i

  until valid_categories.include?(category)
    print('Categoria inválida! Escolha a categoria: ')
    category = gets.chomp.to_i
  end

  filtered_itens = Tarefa.find_by_category(category)

  if filtered_itens.length.zero?
    puts('Nenhum item encontrado.')
    puts('__________________________________')
  else
    puts("#{filtered_itens.length} iten(s) encontrado(s):\n\n")
    list(filtered_itens)
  end

  print('Escolha o item a excluir: ')
  excluir = gets.chomp.to_i

  valid_itens = (1..filtered_itens.size).to_a

  until valid_itens.include?(excluir)
    print('Opção inválida! Escolha o item: ')
    excluir = gets.chomp.to_i
  end

  Tarefa.delete_by_name(filtered_itens[excluir - 1].title)
  # puts("Chamar método de exclusão do item #{excluir}.")

end

loop do
  menu
  case @option
  when 1
    create_item
    print("Pressione 'Enter' para continuar")
    gets
  when 2
    clear
    list(@itens)
    print("Pressione 'Enter' para continuar")
    gets
  when 3
    search_by_keyword
    print("Pressione 'Enter' para continuar")
    gets
  when 4
    search_by_category
    print("Pressione 'Enter' para continuar")
    gets
  when 5
    delete
    print("Pressione 'Enter' para continuar")
    gets
  when 6
    break
  end
end
clear
puts 'Obrigado por usar o diário de estudos'
