require "gosu"

class Enemy
    attr_reader :x, :y, :radius
    def initialize(window, image)
        @radius = 40

        #Randomize x-coordinate when spawning the enemy
        @x = rand(window.width - 2 * @radius) + @radius
        @y = 0

        #Randomize the speed of the enemy
        @Speed = rand(5) + 1
        @image = Gosu::Image.new(image)
    end

    #Move the enemy by incresing its y-coordinate
    def move
        @y += @Speed
    end

    #Draw the enemy object within the window
    def draw
        @image.draw(@x - @radius, @y - @radius, 1)
    end

end