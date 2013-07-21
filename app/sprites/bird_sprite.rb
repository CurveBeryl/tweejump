class BirdSprite < Joybox::Core::Sprite

	attr_accessor :velocity
	attr_accessor :acceleration

	def initialize
	end
	
	def look_right?
		@look_right
	end

	def look_right=is_right
		self.scaleX = is_right ? 1 : -1
		@look_right = is_right
	end

	def reset
		setPosition [160, 160]
		@velocity = CGPoint.new 0, 0
		@acceleration = CGPoint.new 0, -550

		@look_right = true
		look_right=true

		@max_x = Screen.width - self.contentSize.width/2
		@min_x = self.contentSize.width/2
	end

	def jump
		@velocity.y = 350
	end

	def move direction
		@acceleration.x = direction == :left ? -200 : 200
	end

	def stop
		@acceleration.x = 0
	end

	def step dt
		position = self.position

		position.x += @velocity.x * dt

		if @velocity.x < -30 && look_right?
			look_right false
		elsif @velocity.x > 30 && !look_right?
			look_right false
		end

		# Handle screen bounds
		position.x = @max_x if position.x > @max_x
		position.x = @min_x if position.x < @min_x

		# Phisics imitation
		@velocity.y += @acceleration.y * dt
		position.y += @velocity.y * dt

		position.x += @acceleration.x * dt


		setPosition position

	end
end