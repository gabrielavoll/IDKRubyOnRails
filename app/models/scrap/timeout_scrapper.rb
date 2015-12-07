class TimeoutScrapper < AbstractScrapper 
	attr_accessor :timouturl
	TIMEOUT_SOURCE = "myfreeconcerts"

	def initialize
		message = "Timeout Scrap Start"
		super(message)		#call absract scrapper class
		@basetimeouturl = "http://www.timeout.com"
		@timeoutsurl = @basetimeouturl + "/newyork/things-to-do/things-to-do-in-new-york-today"
	end

	#no pagination
	def scrap
		html = pullHtml(@timeoutsurl)
		events = html.css("#tab__panel_1 .small_list .tiles article")

		events.each do |e|
			container =  e.css(".feature-item__content .row")

			leftcontainer = container.css(".feature-item__column")[0]
			rightcontainer = container.css(".feature-item__column")[1]
			
			name = rightcontainer.css("h3").text

			link = @basetimeouturl + leftcontainer.css("a")[0]["href"]
			imglink = leftcontainer.css("img")[0]["src"]

			description = rightcontainer.css("p").text			

			lat, long, address, startdate, enddate, price, types = deepscrap(link)

			@eventcount += 1 
			EventResult.create!( 
				name: name, 
				price: price, 
				lat: lat, 
				long: long, 
				address: address, 
				imageurl: imglink, 
				eventurl: link , 
				startdate: startdate, 
				enddate: enddate, 
				description: description, 
				types: types, 
				source: TIMEOUT_SOURCE
			)
		end
		message = "Timeout Done"
		endScrapOutput( message, @eventcount.to_s )
	end


	def deepscrap(link)
		html = pullHtml(link)

		typecontainer= html.css(".page_tags .page_tag")
		types = ""
		typecontainer.each do |t|
			types += explodeImplode(t)
		end

		addresscontainer = html.css("#tab___content_2 .listing_details tbody tr")[1]
		
		address = explodeImplode(addresscontainer.css("td"))
		lat, long = calculateGeo(address)

		todayinstance = html.css("#tab___content_3 .occurrences__occurrence_day")[0]

		startdate =  todayinstance.css(".occurrence__time").nil? ? "" : @time.to_date.to_s + " " + findAddTimeSufix(explodeImplode(todayinstance.css(".occurrence__time"))) 
		enddate = ""

		if todayinstance.css(".occurrence__price").empty?
			price = 0
		elsif todayinstance.css(".occurrence__price") =~ /\d/  
			price = cleanMoney(explodeImplode(todayinstance.css(".occurrence__price")).split("-")[0])
		else 
			price = explodeImplode(todayinstance.css(".occurrence__price"))
		end

		return lat, long, address, startdate, enddate, price, types
	end

end