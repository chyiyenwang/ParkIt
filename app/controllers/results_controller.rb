class ResultsController < ApplicationController
	
	def index
		checkin = (params[:checkin].nil? ? "" : params[:checkin].join("/"))+" "+(params[:checkin_time].nil? ? "" : params[:checkin_time].join("/"))
		checkout = (params[:checkout].nil? ? "" : params[:checkout].join("/"))+" "+(params[:checkout_time].nil? ? "" : params[:checkout_time].join("/"))
		if (params[:city] && params[:parking_quantity]).present? && checkin != " " && checkout != " "
	 		@city = Property.near(params[:city], 20)
	 		@properties = @city.where("parking_quantity >= ?", params[:parking_quantity].to_i)
	 		#make this a method
	 		@properties.each do |property|
	 			res = Reservation.where("property_id = ? AND checkin >= ? AND checkout <= ?", property.id, checkin, checkout)
	 			property.available = property.parking_quantity - res.length
	 		end
	 		# @reservations = @properties.joins(:reservations).where("checkin >= ?", params[:checkin]).where("checkout <= ?", params[:checkout])

			@hash = Gmaps4rails.build_markers(@properties) do |property, marker|
			  marker.lat property.latitude
			  marker.lng property.longitude
			  marker.infowindow property.title
			end
		else
			@properties = Property.all
			# make this into a method
			@properties.each do |property|
	 			res = Reservation.where("property_id = ? AND checkin >= ? AND checkout <= ?", property.id, nil, nil)
	 			property.available = property.parking_quantity - res.length
	 		end
			@hash = Gmaps4rails.build_markers(@properties) do |property, marker|
			  marker.lat property.latitude
			  marker.lng property.longitude
			  marker.infowindow property.title
			end
		end
	end

	def show
		@property = Property.find params[:id]
		flash[:danger] = "You must log in to reserve parking."
	end

end
