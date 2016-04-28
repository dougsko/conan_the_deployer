require "conan_the_deployer/version"
require "conan_the_deployer/deployment"
require "conan_the_deployer/config"

module ConanTheDeployer
    DEFAULT_CONFIG_DIR = "#{ENV["HOME"]}/Desktop/conan_the_deployer"    
    DEFAULT_DEPLOYMENTS_DIR = "#{ENV["HOME"]}/Desktop/conan_the_deployer/deployments"
end
