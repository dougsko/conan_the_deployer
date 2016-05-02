#!/usr/bin/env ruby

require "bundler/setup"
require "conan_the_deployer"
require "highline/import"
require "pp"
require 'fileutils'
require 'shellwords'

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
    choose_element_type
end

def choose_deployment
    say("Choose a deployment:")
    choose do |menu|
        Dir.entries(@config.deployments_folder).delete_if{ |x| ! x.match(/\.yaml/) }.each do |entry|
            d = YAML.load_file("#{@config.deployments_folder}/#{entry}")
            menu.choice(d.name) do 
                @deployment = d
                what_to_do
            end
        end
        menu.choice("Back") { welcome }
    end
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
        menu.choice("Tests") { enter_tests }
        menu.choice("Done") { what_to_do }
    end
end

def enter_vf_page
    add_or_remove = ""
    say("Choose an action")
    choose do |menu|
        menu.choice("Add VF Page") { add_or_remove = "add" }
        menu.choice("Remove VF Page") { add_or_remove = "remove" }
        menu.choice("Done") { what_to_do }
    end

    if(add_or_remove == "add")
        pages = Dir.entries("#{@config.sandbox_root}/src/pages/").delete_if{ |x| x.match(/meta\.xml/)}.push("done")
        loop do
            name = ask("Enter page name or \"done\" to quit: ", pages ) do |q|
                q.readline = true
            end
            break if name == "done"
            @deployment.vf_pages << name
        end
    end

    if(add_or_remove == "remove")
        say("Select a page")
        choose do |menu|
            @deployment.vf_pages.each do |page|
                menu.choice(page) { @deployment.vf_pages.delete(page) }
            end
            menu.choice("Done") do
                @deployment.save(@config.deployments_folder)
                choose_element_type
            end
        end
    end

    @deployment.save(@config.deployments_folder)
    enter_vf_page
end

def enter_apex_class
    add_or_remove = ""
    say("Choose an action")
    choose do |menu|
        menu.choice("Add Apex Class") { add_or_remove = "add" }
        menu.choice("Remove Apex Class") { add_or_remove = "remove" }
        menu.choice("Done") { what_to_do }
    end

    if(add_or_remove == "add")
        classes = Dir.entries("#{@config.sandbox_root}/src/classes/").delete_if{ |x| x.match(/meta\.xml/)}.push("done")
        loop do
            name = ask("Enter class name or \"done\" to quit: ", classes ) do |q|
                q.readline = true
            end
            break if name == "done"
            @deployment.apex_classes << name
        end
    end

    if(add_or_remove == "remove")
        say("Select a class")
        choose do |menu|
            @deployment.apex_classes.each do |apex|
                menu.choice(apex) { @deployment.apex_classes.delete(apex) }
            end
            menu.choice("Done") do
                @deployment.save(@config.deployments_folder)
                choose_element_type
            end
        end
    end

    @deployment.save(@config.deployments_folder)
    enter_apex_class
end

def enter_tests
    add_or_remove = ""
    say("Choose an action")
    choose do |menu|
        menu.choice("Add Test Class") { add_or_remove = "add" }
        menu.choice("Remove Test Class") { add_or_remove = "remove" }
        menu.choice("Done") { what_to_do }
    end

    if(add_or_remove == "add")
        classes = Dir.entries("#{@config.sandbox_root}/src/classes/").delete_if{ |x| x.match(/meta\.xml/)}.push("done")
        loop do
            name = ask("Enter test class name or \"done\" to quit: ", classes ) do |q|
                q.readline = true
            end
            break if name == "done"
            @deployment.tests << name
        end
    end

    if(add_or_remove == "remove")
        say("Select a test class")
        @deployment.tests.each do |test|
            menu.choice(test) { @deployment.tests.delete(test) }
        end
        menu.choice("Done") do
            @deployment.save(@config.deployments_folder)
            choose_element_type
        end
    end
    @deployment.save(@config.deployments_folder)
    choose_element_type
end

def what_to_do
    say("What would you like to do with #{@deployment.name}?")
    choose do |menu|
        menu.choice("Show deployment") { pp @deployment; what_to_do }
        menu.choice("Edit elements in deployment") { choose_element_type }
        menu.choice("Verify") { verify }
        menu.choice("Deploy") { }
        menu.choice("Back") { welcome }
    end
end

def verify
    begin
        cleanup
        Dir.mkdir("#{@config.deployments_folder}/#{@deployment.name}")
        Dir.mkdir("#{@config.deployments_folder}/#{@deployment.name}/classes")
        Dir.mkdir("#{@config.deployments_folder}/#{@deployment.name}/pages")
    rescue
    end

    make_diff

    @deployment.apex_classes.each do |apex|
        FileUtils.cp("#{@config.sandbox_root}/src/classes/#{apex}", "#{@config.deployments_folder}/#{@deployment.name}/classes")
        FileUtils.cp("#{@config.sandbox_root}/src/classes/#{apex}-meta.xml", "#{@config.deployments_folder}/#{@deployment.name}/classes")
    end

    @deployment.vf_pages.each do |page|
        FileUtils.cp("#{@config.sandbox_root}/src/pages/#{page}", "#{@config.deployments_folder}/#{@deployment.name}/pages")
        FileUtils.cp("#{@config.sandbox_root}/src/pages/#{page}-meta.xml", "#{@config.deployments_folder}/#{@deployment.name}/pages")
    end

    xml = ConanTheDeployer.make_package(@deployment)
    File.open("#{@config.deployments_folder}/#{@deployment.name}/package.xml", 'w') do |f|
        f.puts xml.target!
    end

    xml = ConanTheDeployer.make_build(@config, @deployment)
    File.open("#{@config.deployments_folder}/build.xml", 'w') do |f|
        f.puts xml.target!
    end

    FileUtils.cd(@config.deployments_folder)
    system("ant #{@deployment.name}")
    #cleanup
    what_to_do

end

def make_diff
    @deployment.apex_classes.each do |apex|
        system("git diff #{Shellwords.escape(@config.prod_root)}/src/classes/#{apex} #{Shellwords.escape(@config.sandbox_root)}/src/classes/#{apex} >> #{@config.deployments_folder}/#{@deployment.name}/#{@deployment.name}.diff")
    end
end

def cleanup
    FileUtils.rm_r("#{@config.deployments_folder}/#{@deployment.name}")
    FileUtils.rm_r("#{@config.deployments_folder}/build.xml")
end

load_config
welcome
