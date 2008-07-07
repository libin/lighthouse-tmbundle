#!/usr/bin/env ruby -s

require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse.rb"
# require "/Users/alexey/Library/Application Support/TextMate/Bundles/Lighthouse.tmbundle/Support/lib/lighthouse.rb"

new_state = $state || 'new'
ticket_id = $id.to_i || 0

TM_LH_ACCOUNT = $account || ''
TM_LH_TOKEN   = $token || 0
TM_LH_PROJECT = $project.to_i || 0

Lighthouse.account = TM_LH_ACCOUNT
Lighthouse.token   = TM_LH_TOKEN

ticket = Lighthouse::Ticket.find(ticket_id, :params => {:project_id => TM_LH_PROJECT})
ticket.state = new_state
ticket.save

print "done"