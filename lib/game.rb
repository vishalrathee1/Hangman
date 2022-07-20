require 'yaml'
require 'json'


class Player
    attr_accessor :lives
    def initialize
        @lives = 10
    end

end

class Game
    def initialize
        @word_to_guess = []
        @guess = ''
        @board = []
        @prev_guesses = []
        @lives = 0
        @winner = false
    end
    
    def select_word
        word_array = [] 
        words = File.open('google-10000-english-no-swears.txt')
        words.each do |word|
        if word.length >5 && word.length <12
            word_array << word.chomp
        end
        end
        return word_array[rand(0...word_array.length)]
    end

    def update_board
        @word_to_guess.each_char.with_index do |word, indx| 
            if word == @guess
                @board[indx] = @guess
            elsif @board[indx] == nil || @board[indx] == "_ "*@word_to_guess.length
                @board[indx] = "_ "
            end
        end
        p @board
    end

    def check_winner
        if @word_to_guess.split("") == @board
            @winner = true
            puts "Yay You win!"
        end
    end

    def check_guess
        if @word_to_guess.include?(@guess)
            update_board
        elsif @prev_guesses.include?(@guess)
            puts "Already guessed! Not in word"
            p @prev_guesses
        else
            @prev_guesses << @guess
            p @prev_guesses
            @lives -= 1
            puts "lives left = #{@lives}"
        end
    end            

    def load_saved_game
        if !Dir.exist?("saved_games")
            return "No saved files found"

        else
            puts Dir.entries("saved_games")
            puts "Select the file you want to load"
            file = gets.chomp.downcase
            update = File.open("saved_games/#{file}", 'r')
            updates = Psych.load_file("saved_games/#{file}")
            @word_to_guess = updates[:word2guess]
            @guess = updates[:guess]
            @board = updates[:board]
            @prev_guesses = updates[:prev_guesses]
            @lives = updates[:lives]
            @winner = updates[:winner]
            update.close
        end
    end

    def save_game

        if Dir.exist?("saved_games")
            puts "enter the name of the file in .yaml (or .json) format (eg. file_name.yaml/file_name.json)"
            filename = gets.chomp.strip 
            if File.exist?("/saved_games/#{filename}")
                stats = File.open("saved_games/#{filename}", 'a')
                stats[
                    word2guess: @word_to_guess,
                    guess: @guess,
                    board: @board,
                    prev_guesses: @prev_guesses,
                    lives: @lives,
                    winner: @winner
                ]
            else 
                File.open("saved_games/#{filename}", "w") do |file|
                file.write({
                    word2guess: @word_to_guess,
                    guess: @guess,
                    board: @board,
                    prev_guesses: @prev_guesses,
                    lives: @lives,
                    winner: @winner}.to_yaml)

                end
                puts "file saved"
            end 
        else
            Dir.mkdir("saved_games")
            save_game
        end   
    end

    def make_move
        puts "Enter 'save' to save game or else take a guess"
        save = gets.chomp.downcase
        if save == "save"
            save_game
        else
            if save.length>1
                puts "Can't guess more than one word, try again"
                make_move
            else
                @guess = save
            end
        end
    end


    public
    def play_game
        puts "Do you want to play new game or load previously saved game?"
        puts "To load previously saved game enter 'y', else press any other key."
        choice = gets.chomp
        if choice == 'y'
            load_saved_game
        else
            player = Player.new()
            @lives = player.lives 
            @word_to_guess = select_word
            @board = ['_ '*@word_to_guess.length]
        end
        p @board
        while @lives != 0 && @winner == false
            make_move
            check_guess
            if @lives == 0
                puts "Game Over!"
                puts "Word was #{@word_to_guess}"
                break
            end
            check_winner
        end
        puts "Do you want to play again? for yes press 'y' ! "
        response = gets.chomp.downcase
        if response == 'y'
            @winner = false
            new_game = Game.new()
            new_game.play_game
        end
    end
end


game = Game.new
game.play_game
