class LighthouseCache
  def initialize
    @users = {}
  end

  def set(user_id)
    @users[user_id] = Lighthouse::User.find(user_id).name
  end

  def get(user_id)
    return '' if user_id.blank?
    
    self.include?(user_id)
    return @users[user_id]
  end

  def include?(user_id)
    if !@users.keys.include?(user_id)
      self.set(user_id)
    end
  end
end