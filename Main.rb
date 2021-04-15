require "gosu"
require_relative "Player"
require_relative "Enemy"
require_relative "Laser"
require_relative "Explosion"
require_relative "Credit"

#The whole GUI display
class SpaceshipShooter < Gosu::Window

	#Constants that will be used throughout the whole game
	WIDTH = 1200
	HEIGHT = 700
	ENEMY_FREQUENCY = 0.01
	MAX_ENEMIES = 30

#This is to initialise the game and the window size and also the initialise for the start scene
	def initialize
		super(WIDTH,HEIGHT)
		self.caption = "Spaceship Shooter"

		@background_image_start = Gosu::Image.new('media/back_2.png') #Background for start scene
		@background_image_game = Gosu::Image.new('media/bg32.jpg') #Background for during the gameplay
		@scene = :start #This means the program will start with this initialisation
		@cursor = Gosu::Image.new('media/cursor.png') #To set an image to the cursor
		@titleFont = Gosu::Font.new(70, name:'media/moonhouse.ttf') #Font used for title
		@gameFont = Gosu::Font.new(30, name:'media/Orena.ttf') #Font used for general text
	end

	def draw
		#To display out different scenes eg start is the main menu, game is the actual gameplay 
		#and end is the credits scene which marks the end of the game
		case @scene
		when :start
			draw_start

		when :game
			draw_game

		when :end
			draw_end

		end
	end

	def update
		#To update the GUI for different scenes
		case @scene
		when :game
			update_game

		when :end
			update_end

		end
	end

	def button_down(id)
		#To define the buttons and keys used for different scenes
		case @scene
		when :start
			button_down_start(id)

		when :game
			button_down_game(id)

		when :end
			button_down_end(id)

		end
	end

	def draw_start
		#Draw the different elements in the start scene
		@background_image_start.draw(0,0,0)
		@cursor.draw(self.mouse_x, self.mouse_y, 2) #To display the custom cursor

		#To draw out the game title
		@title = @titleFont.draw_text('Spaceship', (WIDTH / 4) + 25, HEIGHT / 4, 1, 1.3, 1.3, Gosu::Color.argb(0xff_d65709))
		@title2 = @titleFont.draw_text('Shooter', (WIDTH / 3) + 30, (HEIGHT / 4) + 70, 1, 1, 1, Gosu::Color.argb(0xff_df8c00))

		#To draw out the instruction at the bottom of the window
		@intruc = @gameFont.draw_text('Press \'Enter\' or  Left-click to Start', (WIDTH / 5) + 30, HEIGHT - (HEIGHT / 4), 1, 1, 1, Gosu::Color.argb(0xff_d7ac64))
	end

	def button_down_start(id)
		#If the user press 'Enter' or Left click, the game will start by running the game initialisation
		if id == Gosu::KbReturn || id == Gosu::MsLeft
			initialize_game
		end
	end

	def initialize_game
		#An array of different enemy designs
		@enemyNum = ['media/Enemies/enemyRed1.png', 'media/Enemies/enemyBlack2.png', 'media/Enemies/enemyGreen4.png', 'media/Enemies/enemyBlue3.png']

		#To create the player object
		@player = Player.new(self)

		#Create empty arrays needed 
		@enemies = []
		@lasers = []
		@explosions = []

		@scene = :game #To run the the game scene

		#Scores counter
		@enemies_appeared = 0
		@enemies_destroyed = 0
		@enemies_escaped= 0

		#Initialise the sound effects and songs needed 
		@explosion_sound = Gosu::Sample.new('media/sfx/explosion.ogg')
		@shoot_sound = Gosu::Sample.new('media/sfx/sfx_laser1.ogg')
		@lose_sound = Gosu::Sample.new('media/sfx/lose.ogg')
		@background_sound = Gosu::Song.new('media/sfx/start.ogg')
		@win_sound = Gosu::Song.new('media/sfx/win.ogg')

		#Font used in the game scene
		@scoreFont = Gosu::Font.new(28)
	end

	def draw_game
		@background_image_game.draw(0,0,0)

		#Draw out the score section
		@scoreFont.draw('Score:' + @enemies_destroyed.to_s, WIDTH - 250, 10,2,1,1,Gosu::Color.argb(0xff_1e110c))

		@scoreFont.draw('Enemies left:' + (MAX_ENEMIES - @enemies_appeared).to_s, WIDTH - 250, 50,2,1,1,Gosu::Color.argb(0xff_1e110c))

		@scoreFont.draw('Enemies escaped:' + (@enemies_escaped).to_s, WIDTH - 250, 90,2,1,1,Gosu::Color.argb(0xff_1e110c))


		@player.draw #draw player object

		#To draw out the enemies in the array
		@enemies.each do |enemy|
			enemy.draw
		end

		#To draw out the laser in the array
		@lasers.each do |laser|
			laser.draw
		end

		#To draw out the explosion in the array
		@explosions.each do |explosion|
			explosion.draw
		end

	end

	def update_game
		#Play the game background music
		@background_sound.play()

		#Define all the controls for the player movement eg left arrow/A to turn left, up arrow/W to move forward,
		#right arrow/D to turn right
		if button_down?(Gosu::KbLeft) || button_down?(Gosu::KbA)
			@player.left 
		end

		if button_down?(Gosu::KbRight) || button_down?(Gosu::KbD)
			@player.right 
		end

		if button_down?(Gosu::KbUp) || button_down?(Gosu::KbW)
			@player.accelerate 
		end

		#Move the player
		@player.move

		#Spawn the enemy until it reaches the maximum enemies allowed
		if rand < ENEMY_FREQUENCY && @enemies_appeared < MAX_ENEMIES
			@enemies.push Enemy.new(self, @enemyNum[rand(4)])
			@enemies_appeared += 1 #Increase the counter everytime an enemy spawn
		end

		#Move the enemy 
		@enemies.each do |enemy|
			enemy.move
		end

		#Move the laser
		@lasers.each do |laser|
			laser.move
		end

		#To check if the laser hits the enemies then it will remove that enemy object and the laser object from the array 
		#and display out the explosion image after that followed by the explode sound effect
		@enemies.dup.each do |enemy|
			@lasers.dup.each do |laser|
				distance = Gosu.distance(enemy.x,enemy.y,laser.x,laser.y)
				if distance < enemy.radius + laser.radius
					@enemies.delete(enemy)
					@lasers.delete(laser)
					@explosions.push(Explosion.new(self,enemy.x,enemy.y))
					@enemies_destroyed += 1
					@explosion_sound.play #To play explosion effect when 
				end
			end
		end

		#Remove the explosion object from the array after it is drawn(finished)
		@explosions.dup.each do |explosion|
			explosion.update
			if explosion.finished
				@explosions.delete(explosion) 
			end
		end

		#Remove the enemiy object from the array if the enemy reaches the bottom of the window
		 @enemies.dup.each do |enemy|
		 	if enemy.y > HEIGHT + enemy.radius
		 		@enemies.delete(enemy)
		 		@enemies_escaped += 1 #Increase the counter for escaped enemy
		 	end
		 end

		 #Remove the laser object from the array if it is no longer in the window
		 @lasers.dup.each do |laser|
		 	@lasers.delete(laser) unless laser.onscreen?
		 end

		 #If the number of enemies destroyed and escaped is the same as the maximum enemies allowed
		 #user wins the level
		 if (@enemies_destroyed + @enemies_escaped) >= MAX_ENEMIES
		 	@win_sound.play() #Play the win music 

		 	#Initialise the end scene to move into the end scene
		 	initialize_end(:count_reached) #Pass in the symbol representing winning the level
		 end

		 #Player dies if crash into enemy
		 @enemies.each do |enemy|
		 	distance = Gosu.distance(enemy.x,enemy.y,@player.x,@player.y)
		 	if (distance < @player.radius + enemy.radius)
		 		@background_sound.stop() #Stop the game background music	 		
		 		@lose_sound.play() #Play the lose music
		 		initialize_end(:hit_by_enemy) #Pass in the symbol representing losing the level by crashing into enemy
		 	end
		 end

		 #Player dies if moves beyond the top of the window
		 if @player.y < -@player.radius
		 	@background_sound.stop() #Stop the game background music
		 	@lose_sound.play() #Play the lose music
		 	initialize_end(:off_top) #Pass in the symbol representing losing the level by crossing the topside window
		 end
	end

	#Define the button for shooting the laser
	def button_down_game(id)
		if id == Gosu::KbSpace || id == Gosu::MsLeft
			@lasers.push Laser.new(self, @player.x, @player.y, @player.angle)
			@shoot_sound.play() #Play the shooting sound effect
		end
	end

	#The initialisation of the end scene
	def initialize_end(result)
		case result

		#Assign the displayed message of the result summary if user win
		when :count_reached
			@message = "Congratulations! You did it! You managed to destroy #{@enemies_destroyed} ships"
			@message2 = "and #{@enemies_escaped} reached the base."

		#Assign the displayed message of the result summary if user crash into the enemy
		when :hit_by_enemy
			@message = "You were hit by an enemy ship."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you shot down #{@enemies_destroyed} enemies ships"

		#Assign the displayed message of the result summary if user crossing the topside window
		when :off_top
			@message = "You got too close to the enemy mothership."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you shot down #{@enemies_destroyed} enemies ships"

		end

		@bottom_message = "Press Enter to play again, or Press Esc to quit."
		@message_font = Gosu::Font.new(30)
		@credits = []

		y = HEIGHT / 3

		#Read every line in the text file and store it into an array
		File.open("credits.txt").each do |line|
			@credits.push(Credit.new(self,line.chomp,WIDTH/3.5,y))
			y += 30 #Increasing the y-coordinate
		end

		@scene = :end #Change the scene to the ending scene
	end
	
	def draw_end
		@background_image_end = draw_rect(0, 0, WIDTH, HEIGHT, Gosu::Color.argb(0xff_1e110c))

		#To clip the rolling of the credits to a box
	    clip_to(0,HEIGHT/5,WIDTH,415) do
	      @credits.each do |credit|
	        credit.draw #To draw out every item(credit) in the array
	      end
	    end 

	    #Draw the elements out in the end scene window
	    draw_rect(0, HEIGHT/5, WIDTH, 4, Gosu::Color.argb(0xff_b32a12), z = 1)
	    @message_font.draw_text(@message, WIDTH / 4, 40, 1, 1, 1, Gosu::Color.argb(0xff_d7ac64))
	    @message_font.draw_text(@message2, WIDTH / 4, 75, 1, 1, 1, Gosu::Color.argb(0xff_d7ac64),)
	    draw_rect(0, HEIGHT - HEIGHT/5, WIDTH, 4, Gosu::Color.argb(0xff_df8c00), z = 1)
	    @message_font.draw_text(@bottom_message, WIDTH / 4, HEIGHT - 100, 1, 1, 1, Gosu::Color.argb(0xff_d65709))
		@cursor.draw(self.mouse_x, self.mouse_y, 2)

	end

	def update_end
		#To make the credit roll 
		@credits.each do |credit|
			credit.move
		end

		#If the credit finishes then it will reset to its original position
		if @credits.last.y < ((HEIGHT / 5) - 20)
			@credits.each do |credit|
				credit.reset
			end
		end

	end

	#To define the buttons for end scene
	def button_down_end(id)

		#Allow the user to restart the game when user press 'Enter' button
		if id == Gosu::KbReturn
			initialize_game

			#Stops the win soundtrack when the game is restarted
			if @win_sound.playing?
				@win_sound.stop()
			end

		#Allow the user to end the program when the user press 'Esc' button
		elsif id == Gosu::KbEscape
			close
		end

	end
end

window = SpaceshipShooter.new
window.show