class Float
  def to_unit
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    index = 0
    value = self.to_f 

    while value > 1024 && index < units.length - 1
      value /= 1024
      index += 1
    end

    "#{value.round(2)} #{units[index]}"
  end
end
