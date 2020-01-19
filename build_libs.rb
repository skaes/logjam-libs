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

depends "libc6"
depends "zlib1g"
depends "openssl"
if codename == "bionic"
  depends "libcurl4"
else
  depends "libcurl3"
end

run "/bin/bash", "-c", "find #{prefix} | xargs touch -h"

after_install <<-"EOS"
#!/bin/bash
ldconfig
EOS
