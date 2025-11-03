Rake::Task["tailwindcss:build"].clear

namespace :tailwindcss do
  desc "Build TailwindCSS with custom input/output"
  task :build do
    input  = Rails.root.join("app/assets/stylesheets/application.tailwind.css")
    output = Rails.root.join("app/assets/builds/application.css")

    sh "bundle exec tailwindcss -i #{input} -o #{output}"
  end
end
