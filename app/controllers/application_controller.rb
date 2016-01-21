class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
	require "restaurant_query_handler"
	include ApplicationHelper  
  include SessionsHelper

  EAT_STATUS = ApplicationHelper::EAT_STATUS
  DO_STATUS = ApplicationHelper::DO_STATUS
  DEFAULT_STATUS = ApplicationHelper::DEFAULT_STATUS
  RANDOM_STATUS = ApplicationHelper::RANDOM_STATUS
  RESULT_STATUS = ApplicationHelper::RESULT_STATUS
  COUNT_STATUS = ApplicationHelper::COUNT_STATUS

  LOGO = ApplicationHelper::LOGO
  DESCRIPTION = ApplicationHelper::DESCRIPTION

	#page functions
  def home
    @logo = LOGO
    @title = "HOME"
    @description = DESCRIPTION
    @javascriptsArray = ApplicationHelper.includeJavascripts(DEFAULT_STATUS); 
  end

  def do
    @logo = LOGO
    @description = DESCRIPTION
    @title = "DO"
    @javascriptsArray = ApplicationHelper.includeJavascripts(DO_STATUS); 
    if params.include?('error') 
      @error_msg, @radius_error, @price_error = ApplicationHelper.formErrorMsg(params, DO_STATUS);
    end
    puts request.remote_ip
    @ip = remote_ip
  end

  def eat 
    @logo = LOGO
    @title = "EAT"
    @description = DESCRIPTION
    @javascriptsArray = ApplicationHelper.includeJavascripts(EAT_STATUS); 
    if params.include?('error') 
      @error_msg, @radius_error, @price_error = ApplicationHelper.formErrorMsg(params, EAT_STATUS);
    end
    puts request.remote_ip
    @ip = remote_ip
  end

  def random
    @logo = LOGO
    @description = "Uncertainty Helper"
    @title = "RANDOM"
    @javascriptsArray = ApplicationHelper.includeJavascripts( RANDOM_STATUS); 
  end

  def results 
    @logo = LOGO
    @description = DESCRIPTION
    @javascriptsArray = ApplicationHelper.includeJavascripts( RESULT_STATUS); 
  	if params.include?("source")
  		@title = params["source"]
  		if @title == EAT_STATUS
  			if ApplicationHelper.validateForm(params, EAT_STATUS)
  				query = RestaurantQueryHandler.new( params["lat"], params["long"], params["radius"], params["price"], params["keyword"])
          @results = query.getRestaurantResults
  			else 
  				redirect_to :action => 'eat', :radius => params["radius"] || "", :price => params["price"] || "", :keyword => params["keyword"] || "", :error => "1", :lat => params["lat"] || "", :long => params["long"] || ""
  			end
  		elsif @title == DO_STATUS
  			if ApplicationHelper.validateForm(params, DO_STATUS)
          @googleKey = Rails.application.secrets.google_api_key; 
          query = EventQueryHandler.new( params["lat"], params["long"], params["radius"], params["price"], params["keyword"])
          @results = query.getEventResults

  			else 
					redirect_to :action => 'do', :radius => params["radius"] || "", :price => params["price"] || "", :keyword => params["keyword"] || "", :error => "1", :lat => params["lat"] || "", :long => params["long"] || ""
  			end
  		else 
  			redirect_to :action => 'error', :error_msg => "Submitted from a not accepted page."
  		end
  	else 
  		redirect_to :action => 'error', :error_msg => "You must submit from either the EAT or DO pages to get Results. You can't just jump to the end!"
  	end
  end

  def error 
    @logo = LOGO
    @title = "ERROR"
    @description = "Problems"
    @javascriptsArray = ApplicationHelper.includeJavascripts(DEFAULT_STATUS) 
  	if params.include?(:error_msg)
  		@error_msg = params[:error_msg]
  	else 
  		@error_msg = "SOMETHING HAPPENED, dont really know what"
  	end
  end

  def access_denied 
    @logo = LOGO
    @title = "ACCESS DENIED"
    @description = "ACCESS DENIED"
    @javascriptsArray = ApplicationHelper.includeJavascripts(DEFAULT_STATUS) 
  end

  ## helper functions 
  def app_logger 
    @@app_logger ||= Logger.new("#{Rails.root}/log/app.log")
  end

  def remote_ip
    app_logger.info(request.remote_ip)
  	if request.remote_ip == '127.0.0.1' ||  request.remote_ip == '::1'
      '108.27.76.225'
    else
      request.remote_ip
    end
  end

end
