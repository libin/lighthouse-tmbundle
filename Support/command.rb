#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/web_preview.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_cache.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_state.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_project.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_ticket.rb"

if !ENV['TM_LH_ACCOUNT'] or !ENV['TM_LH_PROJECT'] or !ENV['TM_LH_TOKEN']
  puts html_head(:window_title => "Lighthouse", :page_title => "Lighthouse", :sub_title => "Error")
  puts <<-HTML
<p><strong>Warning</strong>: for connection with Lighthouse you need this parameters TM_LH_ACCOUNT, TM_LH_PROJECT and TM_LH_TOKEN!</p>
<p>You can make this in "Preferences"->"Advanced"->"Shell Variables". TM_LH_ACCOUNT - account. TM_LH_PROJECT - project. TM_LH_TOKEN - token.</p>
HTML
  abort
end

Lighthouse.account = ENV['TM_LH_ACCOUNT']
Lighthouse.token   = ENV['TM_LH_TOKEN']

begin
  projects = Lighthouse::Project.find :all
rescue
  puts html_head(:window_title => "Lighthouse", :page_title => "Lighthouse", :sub_title => "Error")
  puts <<-HTML
<p><strong>Error</strong>: failure connection with Lighthouse or project was not found.</p>
HTML
  abort
end

Projects = LighthouseProject.new projects
project = Projects.select ENV['TM_LH_PROJECT']
Tickets = LighthouseTicket.new project
States = LighthouseState.new project

core_js   = IO.read("#{ENV['TM_BUNDLE_SUPPORT']}/Core.js")
header_js = <<-JAVASCRIPT
var ENV = {};

ENV['TM_LH_ACCOUNT']     = '#{ENV['TM_LH_ACCOUNT']}';
ENV['TM_LH_TOKEN']       = '#{ENV['TM_LH_TOKEN']}';
ENV['TM_LH_PROJECT']     = '#{ENV['TM_LH_PROJECT']}';
ENV['TM_BUNDLE_SUPPORT'] = '#{ENV['TM_BUNDLE_SUPPORT']}';

var STATE_HASH = #{States.to_json};
JAVASCRIPT

html_header("Lighthouse - #{project.name}", "Lighthouse", %Q{<script type="text/javascript" language="javascript" charset="utf-8">#{header_js}\n\n#{core_js}</script><link rel="stylesheet" href="file://#{ENV['TM_BUNDLE_SUPPORT']}/Core.css" type="text/css" charset="utf-8" media="screen">})

puts "<div id='projects'>Project: #{Projects}</div>"

puts '<div id="tickets">'
puts Tickets
puts '</div>'

html_footer()