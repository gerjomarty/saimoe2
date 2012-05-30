#!/usr/bin/env ruby

require 'optparse'

hostname = 'localhost'
username = db_name = dropbox = nil

opts = OptionParser.new do |opts|
  opts.banner = "#{$PROGRAM_NAME} OPTIONS"
  opts.separator ''

  opts.on('-H', '--host HOST', String, 'Database hostname', "(#{hostname})") {|h| hostname = h}
  opts.on('-u', '--user USERNAME', String, 'Database username') {|u| username = u}
  opts.on('-n', '--name DB_NAME', String, 'Database name') {|n| db_name = n}
  opts.on('-d', '--dropbox FOLDER', String, 'Dropbox folder to dump to - must be public') {|d| dropbox = d.chomp('/')}
  opts.on('-h', '--help', 'Display these options') {puts opts; exit 1}
end
opts.parse!

unless hostname && username && db_name && dropbox
  $stderr.puts opts
  exit 1
end

unless File.directory? dropbox
  $stderr.puts "Error: Folder #{dropbox} does not exist or is not a directory"
  exit 1
end

unless File.absolute_path(dropbox) =~ /\/Public/
  $stderr.puts "Error: database dump must be in Public folder"
  exit 1
end

$stdout.puts "Dumping database to #{dropbox}..."
unless system("pg_dump -Fc --no-acl --no-owner -h #{hostname} -U #{username} #{db_name} > #{dropbox}/#{db_name}.dump")
  $stderr.puts "Error when dumping database: #{$?}"
  exit 1
end

unless system("open #{dropbox}")
  $stderr.puts "Error opening Dropbox folder. This was only written to work with MacOS X."
end

print "Enter URL of file: "
$stdout.flush
url = gets.chomp

$stdout.puts "Dumping database to Heroku..."
unless system("heroku pgbackups:restore DATABASE '#{url}'")
  $stderr.puts "Error when restoring database: #{$?}"
  exit 1
end

$stdout.puts "Removing dump file from #{dropbox}..."
unless system("rm -rf #{dropbox}/#{db_name}.dump")
  $stderr.puts "Error when deleting dump file: #{$?}"
  exit 1
end

$stdout.puts "Pushing latest code to Heroku..."
unless system("git push heroku master")
  $stderr.puts "Error pushing to Heroku: #{$?}"
  exit 1
end

#unless system("heroku run console production utilities/generate_soulmate_keys.rb")
#  $stderr.puts "Error when generating Soulmate keys: #{$?}"
#  exit 1
#end