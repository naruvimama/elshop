module CustomHelpers
  
	PLURAL2CLASS_HASH = {refrigerators:Refrigerator, washingmachines:Washingmachine, airconditioners:Airconditioner, dishwashers:Dishwasher}
	SINGULAR2CLASS_HASH = {refrigerator:Refrigerator, washingmachine:Washingmachine, airconditioner:Airconditioner, dishwasher:Dishwasher}
	P2S= {refrigerators:'refrigerator', washingmachines:'washingmachine', airconditioners:'airconditioner', dishwashers:'dishwasher'}
	S2P = {refrigerator:'refrigerators', washingmachine:'washingmachines', airconditioner:'airconditioners', dishwasher:'dishwashers'}
	PROPERTIES = {doors:'Doors', type:'Type', capacity:'Capacity', loading:'Loading type (Top/Front) ', volume:"Volume"}
  def plural2class(plural)
    PLURAL2CLASS_HASH[plural.to_sym]
	end

  def singular2class(singular)
    SINGULAR2CLASS_HASH[singular.to_sym]
	end

	def plural(singular)
    S2P[singular.to_sym]
	end

	def singular(plural)
    P2S[plural.to_sym]   
	end

	def item_props
		PROPERTIES
	end
	def categories
		['refrigerator', 'washingmachine', 'airconditioner', 'dishwasher']
	end
	def escape_space(x)
		x.gsub /\s/, "%20"
	end
	def unescape_space(x)
		x.gsub /\%20/, " "
	end
end
