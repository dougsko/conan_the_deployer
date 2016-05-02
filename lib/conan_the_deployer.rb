require "conan_the_deployer/version"
require "conan_the_deployer/deployment"
require "conan_the_deployer/config"
require "builder"

module ConanTheDeployer
    module_function

    DEFAULT_CONFIG_DIR = "#{ENV["HOME"]}/Desktop/conan_the_deployer"    
    DEFAULT_DEPLOYMENTS_DIR = "#{ENV["HOME"]}/Desktop/conan_the_deployer/deployments"

    def make_package(deployment)
        xml = Builder::XmlMarkup.new(:indent => 4)
        xml.instruct!
        xml.Package("xmlns" => "http://soap.sforce.com/2006/04/metadata") do
            if(deployment.apex_classes.size > 0)
                xml.types do
                    deployment.apex_classes.each do |apex|
                        xml.members(File.basename(apex, ".cls"))
                    end
                    xml.name("ApexClass")
                end
            end

            if(deployment.vf_pages.size > 0)
                xml.types do
                    deployment.vf_pages.each do |page|
                        xml.members(File.basename(page, ".page"))
                    end
                    xml.name("ApexPage")
                end
            end
            xml.version("31.0")
        end
        return xml
    end

    def make_build(config, deployment)
        xml = Builder::XmlMarkup.new(:indent => 4)
        xml.project("default" => deployment.name, "basedir" => ".", "xmlns:sf" => "antlib:com.salesforce") do
            xml.property("file" => "build.properties")
            xml.property("environment" => "env")

            xml.target("name" => deployment.name) do
                xml.tag!('sf:deploy', { 
                        :username => config.prod_username,
                        :password => config.prod_password + config.prod_token,
                        :serverurl => "https://login.salesforce.com", 
                        :logType => "Debugonly",
                        :deployroot => deployment.name, 
                        :testLevel => "RunSpecifiedTests",
                        :checkOnly => "true"}
                        ) do
                            deployment.tests.each do |test|
                                xml.runTest(File.basename(test, ".cls"))
                            end
                        end


            end
        end
        return xml
    end


end
