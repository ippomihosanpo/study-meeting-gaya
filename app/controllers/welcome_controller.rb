class WelcomeController < ApplicationController
	def index
		@date = Time.now.strftime('%Y%m%d')
	end
	def result
		@date = params[:date] || Time.now.strftime('%Y%m%d')
		@date_format = Date.strptime(@date,'%Y%m%d').strftime('%-m月%-d日')
	end
end
