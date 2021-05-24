module EventsHelper
  def admin?(user, event)
    result = false
    if event.admin == user
      result = true
    end
    result
  end

  def attending?(user, event)
    result = false
    if !event.attendings.nil? && event.attendings.include?(user)
      result = true
    end
    result
  end
end
