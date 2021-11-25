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

def clear
  puts(`clear`)
end

def menu
  @itens = Tarefa.all
  @valid_categories = (1..Categoria.all.size).to_a
  valid_options = (1..options_menu.size).to_a
  @option = 0
  until valid_options.include?(@option)
    clear
    puts('DIÁRIO DE TAREFAS'.green)
    puts(options_menu)
    print('Sua opção: '.green)
    @option = gets.to_i
  end
end

def create_item
  clear
  print('CADASTRAR NOVO ITEM'.green + "\nDigite o nome do item de estudo: ")
  name = gets.chomp

  category = 0
  until @valid_categories.include?(category)
    clear
    puts('CADASTRAR NOVO ITEM'.green)
    Categoria.all.each.with_index(1) { |cat, index| puts("[#{index}] ".green + cat.to_s) }
    print('Defina a categoria: ')
    category = gets.to_i
  end

  clear
  print('CADASTRAR NOVO ITEM'.green + "\nEscreva a descrição do item: ")
  description = gets.chomp

  task = Tarefa.new(category: category, title: name, description: description)
  clear
  puts("Item \"#{task.title}\" da categoria \"#{Categoria.all[category - 1]}\" cadastrado com sucesso.")
  Tarefa.save_to_db(task)
end

def list(itens, number)
  itens.sort_by! { |e| e.category.name }
  Categoria.all.each.with_index(1) do |category, index|
    next unless itens.map { |item| item.category.name.to_i }.uniq.include?(index)

    puts("============ ##{index} - #{category} ============".blue)
    itens.each.with_index(1) do |item, item_index|
      if item.category.name.to_i == index
        print("#{item_index}".green + " - ") if number
        puts(item)
      end
    end
    puts
  end
end

def search_by_keyword
  clear
  print('BUSCAR ITEM DE ESTUDO'.green + "\nDigite o termo desejado: ")
  key = gets.chomp.downcase
  filtered_itens = Tarefa.find_by_keyword(key)
  clear
  pre_list(filtered_itens, false)
end

def search_by_category
  clear
  category = 0

  until @valid_categories.include?(category)
    clear
    puts('BUSCA POR CATEGORIA'.green)
    Categoria.all.each.with_index(1) do |cat, index|
      puts("##{index}".green + " - #{cat}")
    end
    print('Digite a categoria desejada: ')
    category = gets.to_i
  end

  filtered_itens = Tarefa.find_by_category(category)

  clear
  pre_list(filtered_itens, true)
end

def delete_or_done(done)
  clear
  done ? puts('MARCAR COMO FEITO'.green) : puts('EXCLUIR UM ITEM'.green)

  list(@itens, false)
  category = -1

  until @valid_categories.include?(category) || category.zero?
    print('Escolha a categoria [0 p/ voltar]: ')
    category = gets.to_i
  end

  return if category.zero?

  clear
  done ? puts('MARCAR COMO FEITO'.green) : puts('EXCLUIR UM ITEM'.green)

  filtered_itens = Tarefa.find_by_category(category)

  pre_list(filtered_itens, true)

  index = -1
  valid_itens = (0..filtered_itens.size).to_a

  until valid_itens.include?(index)
    print('Escolha o item [0 p/ voltar]: ')
    index = gets.to_i
  end
  task = filtered_itens[index - 1]
  clear
  done ? puts('MARCAR COMO FEITO'.green) : puts('EXCLUIR UM ITEM'.green)
  print("Item \"#{task.title}\" da categoria \"#{Categoria.all[category - 1]}\" ")
  done ? puts('marcado como feito.') : puts('excluído com sucesso.')
  Tarefa.delete_or_done(task, done) unless index.zero?
end

def pre_list(itens, number)
  itens.length.zero? ? puts('Nenhum item encontrado.'.yellow + "\n______________________________") : list(itens, number)
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
    clear
    puts('LISTA DOS ITENS'.green)
    pre_list(@itens, false)
  when SEARCH_BY_TERM
    search_by_keyword
  when SEARCH_BY_CATEGORY
    search_by_category
  when DELETE_ITEM
    delete_or_done(false)
  when MARK_AS_DONE
    delete_or_done(true)
  when LIST_DONE
    clear
    puts('LISTA DOS ITENS FEITOS'.green)
    pre_list(Tarefa.done, false)
  when EXIT
    break
  end
  continue
end
clear
puts 'Obrigado por usar o diário de estudos'
