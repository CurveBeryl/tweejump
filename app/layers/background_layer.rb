class BackgroundLayer < Joybox::Core::Layer
	@@num_clouds = 12
	@@clouds = []
	def on_enter
		@sprite_batch = SpriteBatch.new file_name: "images/sprites.png", capacity: 10
		self << @sprite_batch

		bg_sprite = Sprite.new texture: @sprite_batch.texture, rect: [ [0, 0], [Screen.width, Screen.height]]
		@sprite_batch << bg_sprite
		bg_sprite.position = [Screen.half_width, Screen.half_height]

		init_clouds

		schedule_update do |dt|
			@@clouds.each do |cloud|
				pos = cloud.position
				size = cloud.contentSize
				pos.x += 0.25 * cloud.scaleY
				pos.x = -size.width/2 if pos.x > Screen.width + size.width/2

				cloud.position = pos

				reset_cloud(cloud) if pos.y < -cloud.contentSize.height/2
			end
		end
	end

	def init_clouds
		clouds_rects = [ [ [336, 16], [256, 108] ] , [[338, 128], [257, 110]] , [[336, 240], [252, 119]] ]
		@@num_clouds.times do
			cloud = Sprite.new texture:@sprite_batch.texture, rect: clouds_rects[rand(3)]
			cloud.opacity = 128
			@sprite_batch << cloud
			@@clouds << cloud
			reset_cloud cloud, 0
		end
	end

	def reset_clouds
		@@clouds.each do |cloud|
			reset_cloud cloud
		end
	end

	def reset_cloud cloud, min_y=Screen.height
		distance = rand(20) + 5
		scale = 5.0 / distance
		cloud.setScale scale
		cloud.scaleX = -cloud.scaleX if rand(1) == 0

		cloud.position = [ rand(Screen.width), rand(Screen.height) + min_y]
	end

	def self.move_clouds delta
		@@clouds.each do |cloud|
			pos = cloud.position
			pos.y -= delta * cloud.scaleY * 0.8
			cloud.setPosition pos			
		end
	end
end