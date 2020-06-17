module RubyInstaller
module Runtime # Rewrite from C:/projects/rubyinstaller2-hbuor/lib/ruby_installer/build/components/03_dev_tools.rb
module Components
class DevTools < Base
  def self.depends
    %w[msys2]
  end

  def description
    "MSYS2 and MINGW development toolchain"
  end

  PACKAGES = %w[
    autoconf
    autoconf2.13
    autogen
    automake-wrapper
    automake1.10
    automake1.11
    automake1.12
    automake1.13
    automake1.14
    automake1.15
    automake1.6
    automake1.7
    automake1.8
    automake1.9
    diffutils
    file
    gawk
    grep
    libtool
    m4
    make
    patch
    pkg-config
    sed
    texinfo
    texinfo-tex
    wget
    mingw-w64-binutils
    mingw-w64-crt-git
    mingw-w64-gcc
    mingw-w64-gcc-libs
    mingw-w64-headers-git
    mingw-w64-libmangle-git
    mingw-w64-libwinpthread-git
    mingw-w64-make
    mingw-w64-pkg-config
    mingw-w64-tools-git
    mingw-w64-winpthreads-git
  ]

  def execute(args)
    msys.with_msys_apps_enabled do
      puts "Install #{description} ..."
      packages = PACKAGES.map do |package|
        package.sub(/^mingw-w64/, msys.mingw_package_prefix)
      end
      res = run_verbose("pacman", "-S", *pacman_args, *packages)
      puts "Install #{description} #{res ? green("succeeded") : red("failed")}"
      raise "pacman failed" unless res
    end
  end
end
end
end
end
