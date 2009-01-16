#!/usr/bin/env ruby

require "#{ENV['TM_SUPPORT_PATH']}/lib/web_preview.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_cache.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_state.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_project.rb"

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
tickets = project.tickets

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

html_header("Lighthouse - #{project.name}", "Lighthouse", %Q{<script type="text/javascript" language="javascript" charset="utf-8">#{header_js}\n\n#{core_js}</script><link rel="stylesheet" href="file://#{ENV['TM_BUNDLE_SUPPORT']}/Core.css" type="text/css" charset="utf-8" media="screen">})

puts "<div style='text-align: right;'>Project: #{Projects}</div>"

if tickets.length > 0
  puts '<table class="lighthouse" border="0">'
  puts '<tr><th>№</th><th>Name</th><th class="state">State</th><th>Creator</th><th>Assigned</th></tr>'

  tickets.each do |ticket|
    States.select ticket
    style = States.style_color

    puts "<tr>"
    puts "<td id='number_#{ticket.id}'#{style}><a id='link_#{ticket.id}' href='#{LH_URL}#{ticket.number}-' onclick='openInBrowser(this); return false;'#{style}>\##{ticket.number}</a></td>"
    puts "<td><span class='span_link' onclick='toggleBody(#{ticket.id})'>#{ticket.title}</span></td>"
    puts "<td class='state'>#{States}</td>"
    puts "<td class='creator'>#{Users.get(ticket.creator_id)}</td>"
    puts "<td class='assigned'>#{Users.get(ticket.assigned_user_id)}</td>"
    puts "</tr>"
    puts "<tr>"
    puts "<td colspan=5><div id='body_#{ticket.id}' style='display:none;'>"
    ticket = Lighthouse::Ticket.find(ticket.number, :params => { :project_id => project.id })
    ticket.versions.each do |version|
      puts "<fieldset>"
      puts "<legend>#{Users.get(version.user_id)}</legend>"
      puts version.body_html
      puts "</fieldset>"
    end
    puts "</div></td>"
    puts "</tr>"
  end
  puts "</table>"
end

html_footer()