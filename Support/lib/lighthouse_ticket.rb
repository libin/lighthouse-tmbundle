require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_cache.rb"
require "#{ENV['TM_BUNDLE_SUPPORT']}/lib/lighthouse_state.rb"

class LighthouseTicket
  def initialize project
    Lighthouse.account = ENV['TM_LH_ACCOUNT']
    Lighthouse.token   = ENV['TM_LH_TOKEN']
    
    @project = project
    @tickets = project.tickets
    @users_cache  = LighthouseCache.new
    @states = LighthouseState.new project
    @lh_url = "http://#{ENV['TM_LH_ACCOUNT']}.lighthouseapp.com/projects/#{project.id}/tickets/"
  end

  def to_s
    if @tickets.length > 0
      return <<-TICKETS
<table class="lighthouse" border="0">
<tr><th>№</th><th>Name</th><th class="state">State</th><th>Creator</th><th>Assigned</th></tr>
#{@tickets.map{|t| draw_ticket t}.join}
</table>
TICKETS
    else
      return 'No tickers can be found for this project!'
    end
  end

  def draw_ticket ticket
    @states.select ticket
    style = @states.style_color

    return <<-TICKET
<tr>
  <td id='number_#{ticket.id}'#{style}><a id='link_#{ticket.id}' href='#{@lh_url}#{ticket.number}-' onclick='openInBrowser(this); return false;'#{style}>\##{ticket.number}</a></td>
  <td><span class='span_link' onclick='toggleBody(#{ticket.id})'>#{ticket.title}</span></td>
  <td class='state'>#{@states}</td>
  <td class='creator'>#{@users_cache.get(ticket.creator_id)}</td>
  <td class='assigned'>#{@users_cache.get(ticket.assigned_user_id)}</td>
</tr>
#{draw_versions ticket}
TICKET
  end
  
  def draw_versions ticket
    ticket = Lighthouse::Ticket.find(ticket.number, :params => { :project_id => @project.id })
    return <<-TICKET_VERSIONS
<tr>
  <td colspan=5><div id='body_#{ticket.id}' style='display:none;'>
  #{ticket.versions.map{|v| draw_version v}.join}
  </div></td>
</tr>
TICKET_VERSIONS
  end
  
  def draw_version version
    return <<-TICKET_VERSION
<fieldset>
  <legend>#{@users_cache.get(version.user_id)}</legend>
  #{version.body_html}
</fieldset>
TICKET_VERSION
  end

  private :draw_ticket, :draw_versions, :draw_version
end