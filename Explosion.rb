require "gosu"

class Explosion
    attr_reader :finished
    def initialize (window,x,y)
        @x = x
        @y = y
        @radius = 30
        @images = Gosu::Image.new('media/boom.png')

        #To check the explosion to remove it when it has completed its purpose
        @finished = false
        @imgHeight = @imgWidth = 1
    end

    #To draw the object according to the position of the enemy
    def draw
        @images.draw(@x - @radius, @y - @radius, 2, @imgWidth, @imgHeight)
        @finished = true #To remove the object when it is drawn
    end

    #Randomize the size of the explosion
    def update
        @imgWidth = @imgHeight = rand(3) + 1
    end
end