class LighthouseState
  def initialize open_states, closed_states
    @open   = parse open_states
    @closed = parse closed_states

    @selected = nil
    @ticketid = nil
  end

  def color state = nil
    state = @selected if @selected != nil

    ((@open + @closed).detect do |hash|
      hash[:name] == state
    end)[:color]
  end

  def style_color state = nil
    " style='color: \##{color(state)}'"
  end

  def select ticket
    @selected = ticket.state
    @ticketid = ticket.id
  end

  def to_s
    open  = (@open.collect { |state| draw_option state[:name] }).join('')
    close = (@closed.collect { |state| draw_option state[:name] }).join('')

    select_id = "id='lh_ticket_#{@ticketid}' " if @ticketid > 0
    "<select #{select_id}onchange='changeStatus(this);'><optgroup label='Open status'>#{open}</optgroup><optgroup label='Close status'>#{close}</optgroup></select>"
  end

  def to_json
    states = ((@open + @closed).collect do |state|
      "\"#{state[:name]}\": \"\##{state[:color]}\""
    end).join(',')

    "{#{states}}"
  end

  def draw_option value
    select = " selected='selected'" if @selected == value
    "<option value='#{value}'#{select}>#{value}</option>"
  end

  def parse states
    states.split("\n").collect do |state|
      state_split = state.split("/")
      {:name => state_split[0], :color => state_split[1]}
    end
  end

  private :parse, :draw_option
end