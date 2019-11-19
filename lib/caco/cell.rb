module Caco
  class Cell
    def self.inherited(subclass)
      subclass.include Cell::Erb
      subclass.view_paths = ["lib"]
    end
  end
end
