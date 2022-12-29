prefix = ENV['LOGJAM_PREFIX'] || "/opt/logjam"
suffix = prefix == "/opt/logjam" ? "" : prefix.gsub('/', '-')

name "logjam-libs#{suffix}"

full_version = `#{File.expand_path(__dir__)}/bin/version`.chomp
f_v, f_i = full_version.split('-', 2)

version f_v
iteration f_i

vendor "skaes@railsexpress.de"

# plugin "exclude"
# exclude "#{prefix}/share/man"
# exclude "#{prefix}/share/doc"
# exclude "/usr/share/doc"
# exclude "/usr/share/man"

files "#{prefix}/bin/*"
files "#{prefix}/include/*"
files "#{prefix}/lib/*"
files "#{prefix}/share/*"

keep_modified_files!

depends "libc6"
depends "zlib1g"
depends "openssl"
depends "libuuid1"
depends "libcurl4"

run "/bin/bash", "-c", "find #{prefix} | xargs touch -h"

after_install <<-"EOS"
#!/bin/bash
ldconfig
EOS
