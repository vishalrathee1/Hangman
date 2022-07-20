class Player
    attr_accessor :lives
    def initialize
        @lives = 8
    end

    def make_guess
        puts "Enter any alphabet from a-z"
        guess = gets.chomp.downcase
        return guess
    end
end
