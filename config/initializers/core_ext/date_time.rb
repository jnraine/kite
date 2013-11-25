Time.class_eval do
  def iso8601_no_timezone
    iso8601.gsub(/[-\+]\d+:\d+$/, "")
  end
end