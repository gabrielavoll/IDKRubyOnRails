class EventbriteScrapper < AbstractScrapper
	attr_accessor :pagecount
	EVENTBRITE_SOURCE = 'eventbrite'

	def initilize
		super		#call absract scrapper class
		@pagecount = 1
		@urlbeg = "https://www.eventbrite.com/d/ny--manhattan/events--today/?"
		@urlend = "&slat=40.7831&slng=-73.9712&sort=best"
	end

	def scrap
		#pagination
		loop do 
			page = "page=" + @pagecount.to_s
			puts page
			html = Nokogiri::HTML(open(@urlbeg + page + @urlend))

			events = html.css(".js-event-list-container.l-block-stack div.l-block-2")
			break if events.empty?
			@pagecount += 1

			events.each do |e|
				link =  e.css("a.js-search-result-click-action")[0]["href"]
				imglink = e.css(".list-card__header img")[0]["src"]
				price = e.css(".list-card__header span.list-card__label").text
				name = e.css(".list-card__body .list-card__title").text.split.join(" ")
				date = e.css(".list-card__body .list-card__date").text.split.join(" ")
				address = e.css(".list-card__body .list-card__venue").text.split.join(" ")
				org = e.css(".list-card__body .list-card__organizer").text.split.join(" ")
				geo = e.css(".list-card__body .list-card__venue span[itemprop='geo']")
				lat = geo.css("meta[itemprop='latitude']")[0]["content"]
				long = geo.css("meta[itemprop='longitude']")[0]["content"]
				EventResult.create!( name: name[0..98].gsub(/\s\w+\s*$/,'...'), price: price, lat: lat, long: long, address: address, imageurl: imglink ? imglink : '' , eventurl: link , startdate: date, enddate: "", description: '', types: '', source: EVENTBRITE_SOURCE)
			end
		end
	end

end
