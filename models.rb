DataMapper::setup(:default, 'mysql://chandra:axlefrog@localhost/elshop_dev')

class Brand
	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :created_at, DateTime
	property :updated_at, DateTime
	has n, :appliances
	
	attr_accessor :appliances_count

	validates_presence_of :name
end

class Appliance
	include DataMapper::Resource
	@@options= {}
	property :id, Serial
	property :model_number, String
	property :name, String
	property :star_rating, Integer
	property :product_url, String
	property :product_pic, String
	property :product_pic_small, String
	property :MRP, Integer
	property :price, Integer
	property :colour, String
	property :description, Text
	property :topselling, Boolean
	property :valueformoney, Boolean
	property :toprange, Boolean
	property :item, Discriminator
	belongs_to :brand

	validates_presence_of :model_number, :name, :price, :item
	validates_numericality_of :price, :star_rating
	validates_uniqueness_of :model_number

	after :save do |obj|
		obj.class.rebuild_options
	end
  def self.extract_variants(symb, obj_class)
    @@options[obj_class.inspect] ||= {}
	  @@options[obj_class.inspect][symb]= all(item:obj_class).all(fields:[symb], unique:true, order:[symb.asc]).to_a	
	end
	#def self.rebuild_options
    # @@options[:brand]	= all(item:self).brand.all(fields:[:name])	
  #  [:colour, :star_rating].each do |symb|
	#		extract_variants symb, self
	#	end
	#end

	def self.options
		@@options
	end
end

class Refrigerator < Appliance
	@@options = {}
	property :doors, String
	property :volume, Float

	validates_numericality_of :doors, :volume

	def self.rebuild_options
    [:colour, :star_rating, :doors, :volume].each do |symb|
			extract_variants symb, self
		end
		#super
	end
end

class Washingmachine < Appliance
	@@options = {}
	property :loading, String
	property :capacity, Float

	validates_numericality_of :capacity

	def self.rebuild_options
    [:colour, :star_rating, :loading, :capacity].each do |symb|
			extract_variants symb, self
		end
		#super
	end
end

class Dishwasher < Appliance
	@@options = {}
	property :type, String
	property :capacity, Float

	validates_numericality_of :capacity

	def self.rebuild_options
    [:colour, :star_rating, :type, :capacity].each do |symb|
			extract_variants symb, self
		end
		#super
	end
end

class Airconditioner < Appliance
	@@options = {}
	property :type, String
	property :capacity, Float

	validates_numericality_of :capacity

	def self.rebuild_options
    [:colour, :star_rating, :type, :capacity].each do |symb|
			extract_variants symb, self
		end
		#super
	end
end

class Delivery
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :email, String
	property :phone, String
	property :address_l1, String
	property :address_l2, String
	property :city, String
	property :pincode, Integer
	property :delivery_code, String
	property :cancelled, Boolean, :default => false
	property :delivery_time, DateTime
  property :note, Text
	property :delivered, Boolean
	property :delivered_at, DateTime
	property :delivery_note, Text
  property :created_at, DateTime
  property :updated_at, DateTime	

	has n, :delivery_items
	
	validates_presence_of :name, :email, :phone

  def total_items
		delivery_items.sum(:numbers)
	end
	def total_price
		total = 0
		delivery_items.each {|di| total+= di.numbers + di.price}
		total
	end
	def delivery_code_gen 
    self.delivery_code = "#{Date.today.year} #{Date.today.month} #{Date.today.day} - #{id} - #{total_items}"
		save
	end

	def self.save_delivery(data, cart_items)
		delivery = nil 
		transaction do |t|
			delivery = create name:data["name"], email:data["email"], phone:data["phone"], address_l1:data["address_l1"],address_l2:data["address_l2"],  city:data["city"], pincode:data["pincode"]
			cart_items.each do |k, v|
				c_i = Appliance.get k
				delivery.delivery_items.push( DeliveryItem.create name:c_i.name, model_number:c_i.model_number, numbers:v[:numbers], price:c_i.price, colour:c_i.colour, item_type:c_i.item.inspect, brand:c_i.brand.name )
			end
			delivery.save
			delivery.delivery_code_gen
		end
		delivery
	end

end

class DeliveryItem
	include DataMapper::Resource

	property :id, Serial
	property :model_number, String
	property :name, String
	property :brand, String
	property :price, Integer
	property :colour, String
	property :item_type, String
	property :numbers, Integer
	property :delivered, Boolean
  property :delivered_at, DateTime	
  property :created_at, DateTime
  property :updated_at, DateTime	
	property :delivery_id, Integer

	belongs_to :delivery
end

DataMapper.finalize
# Appliance.auto_migrate!
DataMapper.auto_upgrade!
