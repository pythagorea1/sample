require 'bundler/setup'
require 'sinatra/base'
require 'json'
require 'rest-client'
class ContentofMessage
	def initialize(msg)
		@msg = msg
	end
	def content()
		res = text();
		if (res[0]==1)
		return {
			contentType:1,
			toType:1,
			text:res[1]
		}
		else if(res[0]==2)
		return {
			contentType:2,
			toType:1,
			originalContentUrl:res[2],
			previewImageUrl:res[3]
		}
		else if(res[0]==3)
		return {
			contentType:3,
			toType:1,
			originalContentUrl:res[2],
			previewImageUrl:res[3]
		}
		else if(res[0]==4)
		return {
			contentType:4,
			toType:1,
			originalContentUrl:res[2],
			contentMetadata:{
			AUDLEN:res[3]
		}
		else if(res[0]==7)
		return {
			contentType:7,
			toType:1,
			location:{
			title:res[2],
			latitude:res[3],
			longitude:res[4]
		}
		else if(res[0]==8) #sticker
		return {
			contentType:8,
			toType:1,
			contentMetadata:{
			STKID:res[1],
			STKPKGID:res[2],
			STKVER:res[3]
		}
		}
		else
		{
			canvas: {
			width: 1040,
			height: 1040,
			initialScene: "scene1"
			},
			images: {
			image1: {
				x: 0,
				y: 0,
				w: 1040,
				h: 1040
				}
			},
			actions: {
			openHomepage: {
			type: "web",
		text: "Open our homepage.",
		params: {
			linkUri: "http://google.com/"
			}
		},
		sayHello: {
		type: "sendMessage",
		text: "Say hello.",
		params: {
			text: "Hello, Brown!"
			}
		}
	},
		scenes: {
		scene1: {
		draws: [
        {
          image: "image1",
          x: 0,
          y: 0,
          w: 1040,
          h: 1040
        }
		],
		listeners: [
        {
          type: "touch",
          params: [0, 0, 1040, 350],
          action: "openHomepage"
        },
        {
          type: "touch",
          params: [0, 350, 1040, 350],
          action: "sayHello"
        }
      ]
    }
  }
}
		end
		
	def text()
		flag = @msg.match(/乱数\(([0-9]{1,10})〜([0-9]{1,10})\)/)
		if(flag != nil)
			return [1,"#{rand(flag[1].to_i..flag[2].to_i)}"]
		else
			case @msg
			when "あ"
				return [1,@msg+"じゃないです"]
			when "乱数"
				return [1,"「乱数(範囲)」って打ってください。(ex)乱数(1〜100))"]
			when "ボルト"
				return [2,originalContentUrl:"https://i.ytimg.com/vi/qS0OLh8UrZk/maxresdefault.jpg",
			previewImageUrl:"https://i.ytimg.com/vi/qS0OLh8UrZk/maxresdefault.jpg"]
			when "世田谷公園"
				return [7,"世田谷公園",35.6443926,139.6810879]
			when "スティッカー"
				return [8,"3","332","100"]
			else
				return [1,"あって打ってください"]
			end
		end
	end
end

a = gets.chomp
b = ContentofMessage.new(a)
puts b.text()



class App < Sinatra::Base
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)
    
    params['result'].each do |msg|
    process = ContentofMessage.new(msg['content']['text'])
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: process.content()
      }

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      content_json = request_content.to_json

      RestClient.proxy = ENV["FIXIE_URL"]
      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      })
    end


    "OK"
  end
end

run App
