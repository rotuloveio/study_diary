require_relative 'Tarefa'
require 'colorize'
require 'io/console'

NEW_ITEM           = 1
LIST_ALL           = 2
SEARCH_BY_TERM     = 3
SEARCH_BY_CATEGORY = 4
DELETE_ITEM        = 5
MARK_AS_DONE       = 6
LIST_DONE          = 7
EXIT               = 8

def options_menu
  options = <<~OPTIONS
    [#{NEW_ITEM}] Cadastrar novo item de estudo
    [#{LIST_ALL}] Ver itens cadastrados
    [#{SEARCH_BY_TERM}] Buscar item de estudo
    [#{SEARCH_BY_CATEGORY}] Busca por categoria
    [#{DELETE_ITEM}] Excluir um item
    [#{MARK_AS_DONE}] Marcar como feito
    [#{LIST_DONE}] Listar feitos
    [#{EXIT}] Sair
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
  puts('DIÁRIO DE TAREFAS'.green)
  @itens = Tarefa.all

  options_list = options_menu
  options_list.each { |text| puts(text) }

  print('Sua opção: '.green)

  valid_options = (1..options_list.size).to_a
  input = gets.to_i
  until valid_options.include?(input)
    clear
    puts('DIÁRIO DE TAREFAS'.green)
    options_list.each { |text| puts(text) }
    print('Sua opção: '.green)
    input = gets.to_i
  end
  @option = input
end

def create_item
  clear
  puts('CADASTRAR NOVO ITEM'.green)
  print('Digite o nome do item de estudo: ')
  name = gets.chomp

  categories_list = categories_menu
  categories_list.each.with_index(1) do |text, index|
    print("[#{index}] ".green)
    puts(text)
  end

  valid_categories = (1..categories_list.size).to_a

  print('Defina a categoria: ')
  input = gets.to_i

  until valid_categories.include?(input)
    puts('Categoria inválida!'.yellow)
    categories_list.each.with_index(1) do |text, index|
      print("[#{index}] ".green)
      puts(text)
    end
    input = gets.to_i
  end

  category = input

  print('Escreva a descrição do item: ')
  description = gets.chomp

  task = Tarefa.new(category: category, title: name, description: description)
  Tarefa.save_to_db(task)
end

def list(itens, number)
  itens.sort_by! { |e| e.category.name }
  clear
  puts('LISTA DOS ITENS'.green)
  categories_list = categories_menu
  categories_list.each.with_index(1) do |category, index|
    next unless itens.map { |item| item.category.name.to_i }.uniq.include?(index)

    puts("============ ##{index} - #{category} ============".blue)
    itens.each.with_index(1) do |item, item_index|
      if item.category.name.to_i == index
        print("#{item_index}".green + " - ") if number
        puts("#{item.title}: #{item.description}")
      end
    end
    puts("\n")
  end
  puts '__________________________________'
end

def search_by_keyword
  clear
  puts('BUSCAR ITEM DE ESTUDO'.green)
  print('Digite o termo desejado: ')
  key = gets.chomp.downcase
  filtered_itens = Tarefa.find_by_title(key)

  pre_list(filtered_itens, false)
end

def search_by_category
  clear
  puts('BUSCA POR CATEGORIA'.green)
  categories_list = categories_menu
  categories_list.each.with_index(1) do |text, index|
    print("##{index}".green)
    puts(" - #{text}")
  end
  print('Digite a categoria desejada: ')
  category = gets.to_i

  valid_categories = (1..categories_list.size).to_a

  until valid_categories.include?(category)
    clear
    puts('Categoria inválida!'.yellow)
    categories_list.each.with_index(1) do |text, index|
      print("##{index}".green)
      puts(" - #{text}")
    end
    print('Digite a categoria desejada: ')
    category = gets.to_i
  end

  filtered_itens = Tarefa.find_by_category(category)

  pre_list(filtered_itens, true)
end

def delete_or_done(done)
  clear
  done ? puts('MARCAR COMO FEITO'.green) : puts('EXCLUIR UM ITEM'.green)

  list(@itens, false)
  print('Escolha a categoria [0 p/ voltar]: ')
  categories_list = categories_menu

  valid_categories = (1..categories_list.size).to_a

  category = gets.to_i

  until valid_categories.include?(category) || category.zero?
    print('Categoria inválida! Escolha a categoria [0 p/ voltar]: '.yellow)
    category = gets.to_i
  end

  return if category.zero?

  clear
  done ? puts('MARCAR COMO FEITO'.green) : puts('EXCLUIR UM ITEM'.green)

  filtered_itens = Tarefa.find_by_category(category)

  pre_list(filtered_itens, true)

  print('Escolha o item [0 p/ voltar]: ')
  index = gets.to_i

  valid_itens = (1..filtered_itens.size).to_a

  until valid_itens.include?(index) || index.zero?
    print('Opção inválida! Escolha o item [0 p/ voltar]: '.yellow)
    index = gets.to_i
  end
  item = filtered_itens[index - 1]
  Tarefa.delete_or_done(item, done) unless index.zero?
end

def list_done
  clear
  puts('LISTAR FEITOS'.green)
  filtered_itens = Tarefa.done
  pre_list(filtered_itens, false)
end

def pre_list(itens, number)
  if itens.length.zero?
    puts('Nenhum item encontrado.'.yellow)
    puts('__________________________________')
  else
    puts("#{itens.length} iten(s) encontrado(s):\n\n")
    list(itens, number)
  end
end

def continue
  print('Pressione qualquer tecla para continuar'.green)
  $stdin.getch
end

loop do
  menu
  case @option
  when NEW_ITEM
    create_item
  when LIST_ALL
    list(@itens, false)
  when SEARCH_BY_TERM
    search_by_keyword
  when SEARCH_BY_CATEGORY
    search_by_category
  when DELETE_ITEM
    delete_or_done(false)
  when MARK_AS_DONE
    delete_or_done(true)
  when LIST_DONE
    list_done
  when EXIT
    break
  end
  continue
end
clear
puts 'Obrigado por usar o diário de estudos'
