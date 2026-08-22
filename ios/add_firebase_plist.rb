# Adds GoogleService-Info.plist to the Runner target's resources so it is
# bundled into the iOS app. Runs on the Codemagic Mac build machine (no local
# Xcode needed). Idempotent — safe to run on every build.
require 'xcodeproj'

project_path = File.join(File.dirname(__FILE__), 'Runner.xcodeproj')
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'Runner' }
name = 'GoogleService-Info.plist'

if target.nil?
  puts "ERROR: Runner target not found"
  exit 1
end

if target.resources_build_phase.files.any? { |f| f.display_name == name }
  puts "#{name} is already in the Runner target — nothing to do."
else
  group = project.main_group.find_subpath('Runner', true)
  ref = group.files.find { |f| f.display_name == name } || group.new_file(name)
  target.add_resources([ref])
  project.save
  puts "Added #{name} to the Runner target."
end
