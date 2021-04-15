require "gosu"
require_relative "Laser"

class Player
    ROTATION_ANGLE = 5 #Speed of the rotation
    ACCELERATION = 1 #Acceleration of player
    FRICTION = 0.9 #Friction to slow player down
    attr_reader :x, :y, :angle, :radius

    def initialize(window)
        @x = window.width/2
        @y = window.height
        @angle = 0
        @image = Gosu::Image.new('media/playerShip1_orange.png')
        @velx = 0
        @vely = 0
        @radius = 40
        @window = window
    end

    def draw
        @image.draw_rot(@x,@y,1,@angle) #To draw the image that can rotate
    end

    #Increase the angle of the player which rotates the player to the right 
    def right
        @angle += ROTATION_ANGLE
    end

    #Decrease the angle of the player which rotates the player to the left
    def left
        @angle -= ROTATION_ANGLE
    end

    #To enable the player to increase its speed according to its direction 
    def accelerate
        @velx += Gosu.offset_x(@angle,ACCELERATION)
        @vely += Gosu.offset_y(@angle,ACCELERATION)
    end

    #The movement of player spaceship
    def move
        @x += @velx
        @y += @vely

        #To introduce friction to the player so that it can slow down
        @velx *= FRICTION
        @vely *= FRICTION

        #To stop the player from moving out of the left of the window
        if @x > @window.width - @radius
            @velx = 0
            @x = @window.width - @radius
        end

        #To stop the player from moving out of the right of the window
        if @x < @radius
            @velx = 0
            @x = @radius
        end

        #To stop the player from moving out of the bottom of the window
        if @y > @window.height - @radius
            @vely = 0
            @y = @window.height - @radius
        end
    end

end