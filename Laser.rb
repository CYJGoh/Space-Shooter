require "gosu"

class Laser
    SPEED = 15
    attr_reader :x, :y, :radius
    def initialize(window,x,y,angle)
        @x = x
        @y = y
        @direction = angle #Assign it according to the direction the player is facing
        @image = Gosu::Image.new('media/Lasers/dotred.png')
        @radius = 11
        @window = window
    end

    #To move the laser according to the direction player is facing 
    def move
        @x += Gosu.offset_x(@direction,SPEED)
        @y += Gosu.offset_y(@direction,SPEED)
    end

    #To draw out the laser
    def draw
        @image.draw(@x - @radius, @y - (3 * @radius), 1)
    end

    #To check whether laser is in the window or not
    def onscreen?
        right = @window.width + @radius
        left = -@radius
        top = -@radius
        bottom = @window.height + @radius
        @x > left and @x < right and @y > top and @y < bottom
    end
end