class Category
  attr_accessor :id, :category

  def initialize(id, category = nil)
    @id = id
    @category = category
  end

  def to_s
    "#{@id} : #{@category}"
  end
end
