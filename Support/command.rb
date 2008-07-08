#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/web_preview.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_cache.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_state.rb"

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
  project = Lighthouse::Project.find(ENV['TM_LH_PROJECT'])
rescue
  puts html_head(:window_title => "Lighthouse", :page_title => "Lighthouse", :sub_title => "Error")
  puts <<-HTML
<p><strong>Error</strong>: failure connection with Lighthouse or project was not found.</p>
HTML
  abort
end

LH_URL = "http://#{ENV['TM_LH_ACCOUNT']}.lighthouseapp.com/projects/#{project.id}/tickets/"

Users  = LighthouseCache.new
States = LighthouseState.new project.open_states, project.closed_states

core_js   = IO.read("#{ENV['TM_BUNDLE_SUPPORT']}/Core.js")
header_js = <<-JAVASCRIPT
var ENV = {};

ENV['TM_LH_ACCOUNT']     = '#{ENV['TM_LH_ACCOUNT']}';
ENV['TM_LH_TOKEN']       = '#{ENV['TM_LH_TOKEN']}';
ENV['TM_LH_PROJECT']     = '#{ENV['TM_LH_PROJECT']}';
ENV['TM_BUNDLE_SUPPORT'] = '#{ENV['TM_BUNDLE_SUPPORT']}';

var STATE_HASH = #{States.to_json};
JAVASCRIPT

html_header("Lighthouse", "Lighthouse", %Q{<script type="text/javascript" language="javascript" charset="utf-8">#{header_js}\n\n#{core_js}</script>})

if project.tickets.length > 0
  puts '<table class="status" border="0">'
  project.tickets.each do |ticket|
    States.select ticket
    style = States.style_color

    puts "<tr>"
    puts "<td id='number_#{ticket.id}'#{style}>#{ticket.number}</td>"
    puts "<td><a id='link_#{ticket.id}' href='#{LH_URL}#{ticket.number}-' onclick='openInBrowser(this); return false;'#{style}>#{ticket.title}</a></td>"
    puts "<td>#{States}</td>"
    puts "<td>#{Users.get(ticket.creator_id)}</td>"
    puts "<td>#{Users.get(ticket.assigned_user_id)}</td>"
    puts "</tr>"
  end
  puts "</table>"
end

html_footer()