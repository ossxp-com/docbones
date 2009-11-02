
$:.unshift('lib')

require 'bones'
Bones.setup

PROJ.name = 'docbones'
PROJ.authors = 'cuirui'
PROJ.email = 'cuirui@ossxp.com'
PROJ.url = 'http://www.ossxp.com'
PROJ.version = Bones::VERSION
PROJ.release_name = 'Maxilla'
PROJ.ruby_opts = %w[-W0]
PROJ.readme_file = 'README.rdoc'
PROJ.ignore_file = '.gitignore'
PROJ.exclude << 'docbones.gemspec'

PROJ.rubyforge.name = 'codeforpeople'

PROJ.rdoc.remote_dir = 'docbones'
PROJ.rdoc.exclude << '^data/'
PROJ.notes.exclude = %w(^README\.txt$ ^data/ ^tasks/setup.rb$)

PROJ.spec.opts << '--color'

PROJ.ann.email[:server] = 'smtp.gmail.com'
PROJ.ann.email[:port] = 587
PROJ.ann.email[:from] = 'Tim Pease'

PROJ.gem.extras[:post_install_message] = <<-MSG
--------------------------
 Keep rattlin' dem bones!
--------------------------
MSG

PROJ.ann.paragraphs = %w[install synopsis features requirements]
PROJ.ann.text = PROJ.gem.extras[:post_install_message]

task :default => 'spec:specdoc'
task 'ann:prereqs' do
  PROJ.name = 'Mr Bones'
end

PROJ.gem.development_dependencies.clear

depend_on 'rake'

# EOF
