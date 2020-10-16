require 'erb'
require './lib/game_manager'

note_template = ERB.new(File.read('./txts/important_note.erb'))
puts note_template.result(binding) + "\n"

GameManager.new.play
