class Credit
    SPEED = 0.5 #Speed the credits is moving
    attr_reader :y

    def initialize(window, text, x, y)
        @x = x
        @y = @initial_y = y
        @text = text
        @font = Gosu::Font.new(28)
    end

    #To move the credits by reducing the y-coordinate (moving it up the window)
    def move
        @y -= SPEED
    end

    #To display out the credits
    def draw
        @font.draw_text(@text, @x, @y, 1)
    end

    #To reset the credits back to its original position
    def reset
        @y = @initial_y
    end
end