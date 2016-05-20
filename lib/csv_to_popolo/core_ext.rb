class String
  def to_snake_case
    downcase.gsub(/\s+/, '_').gsub(/\W+/, '')
  end
end
