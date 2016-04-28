require "yaml"

module ConanTheDeployer
    class Config
        attr_accessor :prod_username, :prod_password, :prod_token, :sandbox_username, :sandbox_password, :sandbox_token, :deployments_folder, :prod_root, :sandbox_root, :config_folder

        def initialize
            @prod_username
            @prod_password
            @prod_token

            @sandbox_username
            @sandbox_password
            @sandbox_token

            @deployments_folder
            @prod_root
            @sandbox_root
            @config_folder = ConanTheDeployer::DEFAULT_CONFIG_DIR
        end

        def save
            File.open(self.config_folder + "/config.yaml", "w") do |f|
                f.puts YAML.dump(self)
            end
        end
    end
end
