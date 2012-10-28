module Decompiler
  unless File.exists?(Rails.root.join 'vendor', 'libjd-intellij.so')
    raise "Please install libjd-intellij.so in ./vendor.\n" +
           "It can be found at https://bitbucket.org/bric3/jd-intellij"
  end
  require Rails.root.join 'vendor', 'jd-core-java-1.0.jar'

  JdCore = Java::JdCore::Decompiler

  def self.jar2java(jar, out_dir)
    # Crashes way too often in jdcore. Instead of dying with it
    # We'll acall the CLI
    # JdCore.new.decompile_to_dir(jar.to_s, out_dir.to_s)
    jdcore = Rails.root.join 'vendor', 'jd-core-java-1.0.jar'
    unless system("env", "java", "-jar", jdcore.to_s, jar.to_s, out_dir.to_s);
      raise "Couldn't decompile #{jar} properly. Crashed ?"
      out_dir.unlink
    end
  end

  require Rails.root.join 'vendor', 'dex-ir-1.9.jar'
  require Rails.root.join 'vendor', 'dex-reader-1.12.jar'
  require Rails.root.join 'vendor', 'dex-translator-0.0.9.11.jar'
  require Rails.root.join 'vendor', 'commons-lite-1.12.jar'
  require Rails.root.join 'vendor', 'asm-all-3.3.1.jar'

  Dex2jar = Java::ComGooglecodeDex2jarV3::Dex2jar

  def self.dex2jar(apk, jar)
    Dex2jar.from(apk.to_s).to(jar.to_s)
  end

  def self.decompile(apk, out_dir)
    jar = Tempfile.new(['apk', '.jar'], '/tmp')
    begin
      dex2jar(apk, jar.path)
      jar2java(jar.path, out_dir)
    ensure
      jar.close
      jar.unlink
    end
  end
end
