#!/usr/bin/env ruby -s

require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_ticket.rb"

new_project = $project || ENV['TM_LH_PROJECT']

TM_LH_ACCOUNT = $account || ''
TM_LH_TOKEN   = $token || 0

Lighthouse.account = TM_LH_ACCOUNT
Lighthouse.token   = TM_LH_TOKEN

project = Lighthouse::Project.find(new_project)
Tickets = LighthouseTicket.new project

puts Tickets