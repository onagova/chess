require 'yaml'

class SaveManager
  HEADER_LENGTH = 16

  def initialize
    super_dir = File.join(Dir.home, 'onagova_saves')
    Dir.mkdir(super_dir) unless Dir.exist? super_dir

    @dir = File.join(super_dir, 'chess')
    Dir.mkdir(@dir) unless Dir.exist? @dir
  end

  def open_save_menu(header, *args)
    save_slot = gets_save_slot
    return nil if save_slot.nil?

    basename = "slot#{save_slot}.sv"
    absolute_fname = File.join(@dir, basename)
    f = File.open(absolute_fname, 'w')
    YAML.dump(header[0, HEADER_LENGTH], f)
    args.each { |obj| YAML.dump(obj, f) }
    f.close
    "saved to #{absolute_fname}"
  end

  def open_load_menu
    save_slot = gets_save_slot
    return [nil, nil] if save_slot.nil?

    absolute_fname = list_fnames[save_slot]
    if absolute_fname.nil?
      ["Slot ##{save_slot} is empty.", nil]
    else
      [
        "Loaded from #{absolute_fname}",
        YAML.load_stream(File.open(absolute_fname))
      ]
    end
  end

  private

  def gets_save_slot
    loop do
      print_slots
      print 'Select a save slot (\'c\' to cancel): '
      temp = gets.chomp.downcase

      return nil if temp.downcase == 'c'
      return temp.to_i - 1 if temp.match?(/[1-6]/)

      puts 'Invalid input. Try again...'
      puts ''
    end
  end

  def list_fnames
    fnames = Dir.glob(File.join(@dir, '*.sv')).each_with_object([]) do |v, a|
      basename = File.basename(v)
      a << v if basename.match?(/^slot[0-5]\.sv$/)
      a
    end
    fnames.sort
  end

  def print_slots
    fnames = list_fnames
    (0..5).each do |i|
      str = "#{i + 1}) "

      fname = fnames[i]
      if fname.nil?
        str += '-empty- '
      else
        header = YAML.safe_load(File.open(fname))
        str += "#{header} "
      end

      print str.ljust(HEADER_LENGTH + 4)
      puts '' if i == 2
    end
    puts ''
  end
end
