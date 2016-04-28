class Deployment
    attr_accessor :name, :apex_classes, :vf_pages, :tests

    def initialize(name)
        @name = name
        @apex_classes = []
        @vf_pages = []
        @tests = []
    end
end
