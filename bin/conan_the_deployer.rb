#!/usr/bin/env ruby

require "bundler/setup"
require "conan_the_deployer"
require "highline/import"

puts
puts "\t--------------------\t"
puts "\t|Conan The Deployer|"
puts "\t--------------------\t"
puts

def load_config
    if ! File.directory?(ConanTheDeployer::DEFAULT_CONFIG_DIR)
        Dir.mkdir(ConanTheDeployer::DEFAULT_CONFIG_DIR)
    else
        if File.exists?("#{ConanTheDeployer::DEFAULT_CONFIG_DIR}/config.yaml")
            @config = YAML.load_file("#{ConanTheDeployer::DEFAULT_CONFIG_DIR}/config.yaml")
        else
            @config = ConanTheDeployer::Config.new
            @config.config_folder = ConanTheDeployer::DEFAULT_CONFIG_DIR
            @config.deployments_folder = ConanTheDeployer::DEFAULT_DEPLOYMENTS_DIR
            @config.save
        end
    end
end


def welcome
    say("\nWelcome!")
    choose do |menu|
        menu.choice("Create a new deployment") { new_deployment }
        menu.choice("Work with an existing deployment") { choose_deployment }
        menu.choice("Edit config") { edit_config }
        menu.choice("Exit") do
            say("Goodbye!")
            exit
        end
    end
end

def new_deployment
    name = ask("What is the name of this deployment?")
    @deployment = Deployment.new(name)
    puts @deployment.inspect
    choose_element_type
end

def choose_deployment
end

def edit_config
    loop do
        say("\nEdit Config")
        choose do |menu|
            menu.choice("Prod credentials") { enter_prod_creds }
            menu.choice("Sandbox credentials") { enter_sb_creds }
            menu.choice("Deployments folder") do 
                @config.deployments_folder = ask("Deployments folder: ")
            end
            menu.choice("Prod root") do
                @config.prod_root = ask("Production root: ")
            end
            menu.choice("Sandbox root") do
                @config.sandbox_root = ask("Sandbox root: ")
            end
            @config.save
            menu.choice("Done") do
                welcome
            end
        end
    end
end

def enter_prod_creds
    say("\nEnter Production Credentials")
    @config.prod_username = ask("What is your username?")
    @config.prod_password = ask("What is your password?")
    @config.prod_token = ask("What is your security token?")
    say("\nSaving config...")
    @config.save
    edit_config
end

def enter_sb_creds
    say("\nEnter Sandbox Credentials")
    @config.sandbox_username = ask("What is your username?")
    @config.sandbox_password = ask("What is your password?")
    @config.sandbox_token = ask("What is your security token?")
    say("\nSaving config...")
    @config.save
    edit_config
end

def choose_element_type
    say("\nChoose An Element Type")
    choose do |menu|
        menu.choice("Apex class") { enter_apex_class }
        menu.choice("VF page") { enter_vf_page }
        menu.choice("Done") { what_to_do }
    end
end

def enter_vf_page
end

def what_to_do
end

def enter_apex_class
    classes = Dir.entries("#{@config.sandbox_root}/src/classes/").delete_if{ |x| x.match(/meta\.xml/)}.push("done")
    loop do
        name = ask("Enter class name or \"done\" to quit: ", classes ) do |q|
            q.readline = true
        end
        break if name == "done"
        @deployment.apex_classes << name
    end
    choose_element_type
end

load_config
welcome
