class Item
  attr_accessor :id, :nama, :price, :category

  def initialize(id, nama, price, category = nil)
    @id = id
    @nama = nama
    @price = price
    @category = category
  end

  def to_s
    "#{@id}. #{@nama} #{@price} #{@category}"
  end
end
