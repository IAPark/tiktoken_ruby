require 'test/unit'
require_relative "../build/parallel_docker_build"
require "tmpdir"

class TestParallelDockerBuild < Test::Unit::TestCase
  def setup
    @tmpdir ||= Dir.mktmpdir

    Dir.chdir(@tmpdir) do
      File.write "File0", <<-EOT
      FROM a
      RUN a
      RUN d
    EOT
      File.write "File1", <<-EOT
      FROM a
      RUN a
      RUN d
      RUN f \\
          g
    EOT
      File.write "File2", <<-EOT
      FROM a
      RUN b
      RUN c
      RUN d
    EOT
      File.write "File3", <<-EOT
      FROM a
      RUN b
      RUN c
      RUN d
    EOT
    end
  end

  def teardown
    FileUtils.rm_rf @tmpdir
  end

  private def hd(str)
    "y" + Digest::SHA1.hexdigest(str)
  end

  def test_tasks
    Dir.chdir(@tmpdir) do
      RakeCompilerDock::ParallelDockerBuild.new(%w[ File0 File1 File2 File3 ], task_prefix: "y")
    end

    assert_operator Rake::Task["File0"].prerequisites, :include?, hd("File0File1")
    assert_operator Rake::Task["File1"].prerequisites, :include?, hd("File1")
    assert_operator Rake::Task[hd "File1"].prerequisites, :include?, hd("File0File1")
    assert_operator Rake::Task[hd "File0File1"].prerequisites, :include?, hd("File0File1File2File3")

    assert_operator Rake::Task["File2"].prerequisites, :include?, hd("File2File3")
    assert_operator Rake::Task["File3"].prerequisites, :include?, hd("File2File3")
    assert_operator Rake::Task[hd "File2File3"].prerequisites, :include?, hd("File0File1File2File3")
  end

  def test_common_files
    Dir.chdir(@tmpdir) do
      RakeCompilerDock::ParallelDockerBuild.new(%w[ File0 File1 File2 File3 ], task_prefix: "y")
    end

    assert_equal "FROM a\nRUN a\nRUN d\nRUN f \\\ng\n", read_df(hd "File1")
    assert_equal "FROM a\nRUN a\nRUN d\n", read_df(hd "File0File1")
    assert_equal "FROM a\nRUN b\nRUN c\nRUN d\n", read_df(hd "File2File3")
    assert_equal "FROM a\n", read_df(hd "File0File1File2File3")
  end

  def read_df(fn)
    File.read(File.join(@tmpdir, "/tmp/docker", fn)).each_line.map(&:lstrip).join
  end
end
