Dir['tests/*.rb'].sort.each do |f|
  require('./' + f)
end
