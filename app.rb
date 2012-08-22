require 'sinatra'
require 'sinatra/contrib/all'
require 'data_mapper'
require 'sinatra/authorization'
require 'will_paginate'
require 'will_paginate/data_mapper'
require './models'
require './custom_helpers'

Refrigerator.rebuild_options
Washingmachine.rebuild_options
Airconditioner.rebuild_options
Dishwasher.rebuild_options

helpers do
	def authorization_realm
		settings.authorization_realm
	end
	def authorize(username, password)
    username=="admin" && password=="simbhashinybecky"
	end
	def get_klass(params)
		if params[:item]
			klass = singular2class params[:item]
		elsif params[:items]
      klass = plural2class params[:items]
		end
	end
end
set :authorization_realm, "Protected zone"

helpers CustomHelpers
enable :sessions

# Get the home page
#
get '/' do
	@items = {}
	@items['refrigerators'] = Refrigerator.all :conditions => ["topselling=? or valueformoney=? or toprange=?", true, true, true]
	@items['washingmachines'] = Washingmachine.all :conditions => ["topselling=? or valueformoney=? or toprange=?", true, true, true]
	@items['airconditioners'] = Airconditioner.all :conditions => ["topselling=? or valueformoney=? or toprange=?", true, true, true]
	@items['dishwashers'] = Dishwasher.all :conditions =>  ["topselling=? or valueformoney=? or toprange=?", true, true, true]

	@categories = categories
	erb :home
end

def get_items_with_filter(params)
	klass = get_klass params
	options = klass.options
	items = klass.all
	if params[:property]==:brand
		items = items.all(:brand => params[:value])
	end
	if ! params['property'].nil?
  	items = klass.all( params[:property] => params[:value] ).paginate(:page=>params[:page], :per_page=>8)
	else
  	items =klass.all.paginate(:page=>params[:page], :per_page=>8)
	end
	item_category = params[:items]
	[options, items, item_category]
end

# Show items on display and individual items
#
get '/showcase/:items' do
	@options, @items, @item_category = get_items_with_filter params
	if request.xhr?
		erb :items , :layout => false
	else
		erb :products
	end
end

get '/showcase/:item/:id' do
	klass = get_klass params
	@item = klass.get params[:id]
	@item_category = params[:item]
	erb :item
end

# Admin home (Dashboard) and admin show items list with filter

get '/admin/home' do
	login_required
  erb :admin_home
end

get '/admin/appliances/:items' do
	login_required
	@options, @items, @item_category = get_items_with_filter params
	print @items.inspect
	@admin = true
  erb :products
end

# Admin individual items new, create, edit, update, show, delete
#
def extract_item_params(klass, params)
	data = {}
  klass.properties.each { |p| data[p.name.to_s]=params[p.name.to_s] if params.has_key?( p.name.to_s ) } 
	data['item'] = singular2class data['item']
	data
end
get '/admin/appliances/:item/new' do
	login_required
	@cat = params[:item]
	klass = get_klass params
	@item = klass.new
	@brands = Brand.all
	erb :new_item
end

post '/admin/appliances/:item/create' do
	login_required
	@cat = params[:item]
	klass = get_klass params
	@item = klass.create (extract_item_params klass, params)
	if @item.saved?
		redirect to("/showcase/#{@cat}/#{@item.id}")
	else
		@brands = Brand.all
		erb :new_item
	end
end

delete '/admin/appliances/:item/destroy/:id' do
	login_required
	@cat = params[:item]
	klass = get_klass params
	item = klass.get params[:id]
	item.destroy
	json :success => true
end

get '/admin/appliances/:item/edit/:id' do
	login_required
	@cat = params[:item]
	klass = get_klass params
	@item = klass.get params[:id]
	@brands = Brand.all
	erb :edit_item
end

post '/admin/appliances/:item/update/:id' do
	login_required
	@cat = params[:item]
	klass = get_klass params
	@item = klass.get params[:id]
	@item.attributes =  extract_item_params klass, params
	@item.save
	if @item.saved?
		redirect to("/showcase/#{@cat}/#{@item.id}")
	else
		erb url("/admin/#{@cat}/edit/#{@item.id}")
	end
end

# Admin individual brands new, create, edit, update, index, delete
#
get '/admin/new/brand' do
	login_required
	@brand = Brand.new
	erb :new_brand
end

post '/admin/create/brand' do
	login_required
	@brand = Brand.create params
	if @brand.saved?
		redirect to('/admin/brands')
	else
		erb :edit_brand
	end
end

delete '/admin/destroy/brand/:id' do
	login_required
	brand = Brand.get params[:id]
	if brand.appliances.count() == 0
		brand.destroy
		json :success => true
	else
		json :success => false, :msg => "You still have valid products, remove them first"
	end
end

get '/admin/edit/brand/:id' do
	login_required
	@brand = Brand.get params[:id]
	erb :edit_brand
end

post '/admin/update/brand/:id' do
	login_required
	@brand = Brand.get params[:id]
	@brand.attributes =  {name:params[:name]}
	if @brand.save
		redirect to('/admin/brands')
	else
		erb url("/admin/brand/edit/#{@brand.id}")
	end
end

get '/admin/brands' do
	login_required
	@brands = Brand.all
	@brands.each do |brand|
		brand.appliances_count = brand.appliances.count()
	end
	erb :brands
end

# Shopping cart
#
def add_to_cart(params)
	@appliance = Appliance.get params[:id]
  session[:cart]||={}
	if session[:cart].has_key? @appliance.id
		new_number = session[:cart][@appliance.id][:numbers]+1
		session[:cart][@appliance.id] = {numbers:new_number}.merge( {item_type:(@appliance.item.inspect).downcase, model_name:@appliance.model_number, price:@appliance.price, brand:@appliance.brand.name, appliance_id:@appliance.id, added_at:Time.now.to_s})
	else	
		session[:cart][@appliance.id] = {numbers:1, item_type:(@appliance.item.inspect).downcase, model_name:@appliance.model_number, price:@appliance.price, brand:@appliance.brand.name, appliance_id:@appliance.id, added_at:Time.now.to_s}
	end
end
post '/buy_now' do
	add_to_cart params
	redirect_to '/checkout'
end
get '/cart' do
	session[:cart]||={}
	cart = session[:cart].values
	json cart_items:cart
end
get '/clearcart' do
	session[:cart]= {}
	json success:true
end

post '/cart/add' do
  add_to_cart params
	json success:true
end

delete '/cart/remove' do
	@appliance = Appliance.get params[:id]
  session[:cart]||={}
	if session[:cart].has_key? @appliance.id
		if session[:cart][@appliance.id][:numbers] > 1
			session[:cart][@appliance.id][:numbers] -= 1
		else
			session[:cart].delete @appliance.id
		end
		json :success => true
	else	
		json :success => false
	end
end

# Checkout
#
get '/checkout' do
	erb :checkout
end
get '/delivery_confirmed/:id'do
  @delivery = Delivery.get params[:id]
	erb :delivery_confirmed, :layout => false
end

post '/checkout' do
	cart_items = session[:cart] || []
	data = params["delivery"]
	@delivery = Delivery.save_delivery(data, cart_items )
	if	@delivery.saved?
		session[:cart] = nil
		redirect to( "/delivery_confirmed/#{@delivery.id}")
	else
		redirect to('/checkout')
	end
end
