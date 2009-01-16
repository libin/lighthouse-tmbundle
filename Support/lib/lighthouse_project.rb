class LighthouseProject
  def initialize projects
    @projects = {}
    projects.each{|p| @projects[p.id] = p}
  end

  def select project_id
    project_id = project_id.to_i
    @selected = project_id
    
    return @projects[project_id]
  end

  def to_s
    project_options  = (@projects.collect{ |k, v| draw_option k, "#{v.name} (#{v.open_tickets_count})" }).join('')
    
    "<select onchange='changeProject(this);'>#{project_options}</select>"
  end

  def draw_option id, name
    select = " selected='selected'" if @selected == id
    "<option value='#{id}'#{select}>#{name}</option>"
  end

  private :draw_option
end