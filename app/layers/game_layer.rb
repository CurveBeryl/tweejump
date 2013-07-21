class GameLayer < Joybox::Core::Layer
	@@num_platforms = 10
	@@min_platform_step = 50
	@@max_platform_step = 300

	
	def on_enter
		@sprite_batch = SpriteBatch.new file_name: "images/sprites.png", capacity: 10
		self << @sprite_batch
		
		init_platforms
		init_bird
		init_controls
		init_score

		start_game
	end

	def init_score
		@score_label = CCLabelBMFont.labelWithString "0", fntFile: "Fonts/bitmapFont.fnt"
		self << @score_label
		@score_label.position = [ Screen.half_width, Screen.height - 50]
	end


	def init_platforms
		platforms_rects = [ [[608, 64], [102, 36]], [ [608, 128] , [90, 32]] ]
		@platforms = []
		@@num_platforms.times do
			platform = Sprite.new texture: @sprite_batch.texture, rect: platforms_rects[ rand(1)]
			@sprite_batch << platform
			@platforms << platform
		end

		reset_platforms
	end

	def reset_platforms
		@current_platform_y = -1
		@curent_max_platform_step = 60.0
		@platforms_count = 0

		@platforms.each{ |platform| reset_platform platform }
	end

	def reset_platform platform
		if @current_platform_y < 0
			@current_platform_y = 30
		else
			@current_platform_y += rand( @curent_max_platform_step - @@min_platform_step) + @@min_platform_step
		end

		@curent_max_platform_step += 0.5 if @curent_max_platform_step < @@max_platform_step

		platform.scaleX = -platform.scaleX if rand(1) == 0

		if @current_platform_y == 30
			x = Screen.half_width
		else
			x = rand(Screen.width - platform.contentSize.width/2)
		end

		platform.position = [ x, @current_platform_y]
	end


	def init_bird
		@bird = BirdSprite.new texture: @sprite_batch.texture, rect: [ [608, 16], [44,32] ]
		@sprite_batch << @bird
	end

	def init_controls
		on_touches_began do |touches, event|
			touch = touches.any_object
			location = touch.location
			if location.x < @bird.position.x
				@bird.move :left
			else
				@bird.move :right
			end
		end

		on_touches_ended do |touches, event|
			@bird.stop
		end
	end

	def start_game
		@score = 0
		@score_label.setString "0"
		@game_suspend = false

		reset_platforms
		@bird.reset

		schedule_update do |dt|
			step dt
		end
	end

	def step dt

		return if @game_suspend

		@bird.step dt

		if @bird.velocity.y < 0
			# Bird falling down
			@platforms.each do |platform|
				if CGRectIntersectsRect(platform.bounding_box, @bird.bounding_box)
					@bird.jump
				end
			end

			if @bird.position.y < -@bird.contentSize.height/2
				show_highscores
			end
		elsif @bird.position.y > 240
			pos = @bird.position
			delta = pos.y - 240

			pos.y = 240

			@current_platform_y -= delta

			# So uglu decision :(
			BackgroundLayer.move_clouds delta


			@platforms.each do |platform|
				platform_pos = platform.position
				platform_pos.y -= delta
				platform.setPosition platform_pos

				if platform_pos.y < -platform.contentSize.height/2
					reset_platform platform
				end

			end
			@bird.setPosition pos

			@score += delta.to_i
			@score_label.setString "#{@score}"
		end
	end

	def show_highscores
		start_game
	end
end