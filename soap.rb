#!/usr/bin/env ruby
require 'net/http'
require 'rexml/document'

$wsdl_uri = "http://azuremd2.cloudapp.net/Service1.svc?wsdl"

class NoSecret
	def initialize (uri = $wsdl_uri, password = "geheim")
		@uri = URI(uri)
		@operation = "GetTheSecretPhrase"
		@password = password
	end

	def encrypt
		res = REXML::Document.new send.body
		e = res.elements["*/*/*/GetTheSecretPhraseResult"]
		e.text
	end

	private
	def get_soap_action
		doc = REXML::Document.new Net::HTTP::get(@uri)
		doc.elements["*/wsdl:binding"].each { |e|
			if (e.attributes['name'] == @operation)
				return e.elements["soap:operation"].attributes['soapAction']
			end
		}
	end
	
	def build_req_body
		'<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">' +
			'<Header><password>' + @password + '</password></Header>' +
			'<Body><' + @operation + ' xmlns="http://tempuri.org/" /></Body>' +
		'</Envelope>'
	end

	def send
		Net::HTTP.start(@uri.host, @uri.port) do |http|
			req = Net::HTTP::Post.new(@uri.path)
			req['SOAPAction'] = get_soap_action
			req.content_type = 'text/xml; charset=UTF-8'
			req.body = build_req_body
			http.request(req)
		end
	end

end

puts NoSecret.new().encrypt

