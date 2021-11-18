require_relative 'Tarefa'

def options_menu
  options = <<~OPTIONS
    Cadastrar novo item de estudo
    Ver itens cadastrados
    Buscar item de estudo
    Busca por categoria
    Excluir um item
    Marcar como feito
    Listar feitos
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
    puts "[#{index + 1}] #{text}"
  end
  print('Sua opção: ')

  valid_options = (1..options_list.size).to_a
  input = gets.chomp.to_i
  until valid_options.include?(input)
    clear
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
  puts('CADASTRAR NOVO ITEM')
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

def list(itens, number)
  itens.sort_by! { |e| e.category.name }
  clear
  puts('LISTA DOS ITENS')
  categories_list = categories_menu

  categories_list.each_with_index do |category, index|
    if itens.map{|item| item.category.name.to_i}.uniq.include?(index + 1)
      puts("==== ##{index + 1} - #{category} ====")
      itens.each_with_index do |item, item_index|
        if item.category.name.to_i == index + 1
          print("#{item_index + 1} - ") if number
          puts("#{item.title}: #{item.description}")
        end
      end
      puts("\n")
    end
  end
  puts '__________________________________'
end

def search_by_keyword
  clear
  puts('BUSCAR ITEM DE ESTUDO')
  print('Digite o termo desejado: ')
  key = gets.chomp.downcase
  filtered_itens = Tarefa.find_by_title(key)
  if filtered_itens.length.zero?
    puts('Nenhum item encontrado.')
    puts('__________________________________')
  else
    puts "#{filtered_itens.length} iten(s) encontrado(s):\n\n"
    list(filtered_itens, false)
  end
end

def search_by_category
  clear
  puts('BUSCA POR CATEGORIA')
  categorys_list = categories_menu
  categorys_list.each_with_index do |text, index|
    puts("##{index + 1} - #{text}")
  end
  print('Digite a categoria desejada: ')
  category = gets.chomp

  filtered_itens = Tarefa.find_by_category(category)

  if filtered_itens.length.zero?
    puts('Nenhum item encontrado.')
    puts('__________________________________')
  else
    puts("#{filtered_itens.length} iten(s) encontrado(s):\n\n")
    list(filtered_itens, true)
  end
end

def delete_or_done(done)
  clear
  done ? puts('MARCAR COMO FEITO') : puts('EXCLUIR UM ITEM')

  list(@itens, false)
  print('Escolha a categoria [0 p/ voltar]: ')
  categories_list = categories_menu

  valid_categories = (1..categories_list.size).to_a

  category = gets.chomp.to_i

  until valid_categories.include?(category) || category.zero?
    print('Categoria inválida! Escolha a categoria [0 p/ voltar]: ')
    category = gets.chomp.to_i
  end

  return if category.zero?

  clear
  done ? puts('MARCAR COMO FEITO') : puts('EXCLUIR UM ITEM')

  filtered_itens = Tarefa.find_by_category(category)

  if filtered_itens.length.zero?
    puts('Nenhum item encontrado.')
    puts('__________________________________')
  else
    puts("#{filtered_itens.length} iten(s) encontrado(s):\n\n")
    list(filtered_itens, true)
  end

  print('Escolha o item [0 p/ voltar]: ')
  index = gets.chomp.to_i

  valid_itens = (1..filtered_itens.size).to_a

  until valid_itens.include?(index) || index.zero?
    print('Opção inválida! Escolha o item [0 p/ voltar]: ')
    index = gets.chomp.to_i
  end
  item = filtered_itens[index - 1]
  Tarefa.delete_or_done(item.category.name, item.title, item.description, done) unless index.zero?
end

def list_done
  clear
  puts('LISTAR FEITOS')
  filtered_itens = Tarefa.done
  if filtered_itens.length.zero?
    puts('Nenhum item encontrado.')
    puts('__________________________________')
  else
    puts("#{filtered_itens.length} iten(s) encontrado(s):\n\n")
    list(filtered_itens, false)
  end
end

def continue
  print("Pressione 'Enter' para continuar")
  gets
end

loop do
  menu
  case @option
  when 1
    create_item
  when 2
    list(@itens, false)
  when 3
    search_by_keyword
  when 4
    search_by_category
  when 5
    delete_or_done(false)
  when 6
    delete_or_done(true)
  when 7
    list_done
  when 8
    break
  end
  continue
end
clear
puts 'Obrigado por usar o diário de estudos'
