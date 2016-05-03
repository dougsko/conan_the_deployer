class Deployment
    attr_accessor :name, :apex_classes, :vf_pages, :custom_objects, :tests

    def initialize(name)
        @name = name
        @apex_classes = []
        @vf_pages = []
        @custom_objects = []
        @tests = []
    end

    def save(folder)
        if(! Dir.exists?(folder))
            Dir.mkdir(folder)
        end
        File.open("#{folder}/#{@name}.yaml", "w") do |f|
            f.puts YAML.dump(self)
        end
    end
end
