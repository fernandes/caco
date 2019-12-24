require "test_helper"

class TrablazerPath < Trailblazer::Operation
  step :initial
  # step :repo_exist, Output(Trailblazer::Activity::Left, :credit_card) => Path(end_id: "End.install_repo", end_task: End(:install_repo)) do
  step :repo_exist, Output(Trailblazer::Activity::Left, :credit_card) => Path(connect_to: Id(:create_profile)) do
    step :clone_repo
  end
  step :create_profile
  step :finish_install

  def initial(ctx, **)
    true
  end

  def repo_exist(ctx, **)
    # true
    false
  end

  def clone_repo(ctx, **)
    true
  end

  def create_profile(ctx, **)
    true
  end

  def finish_install(ctx, **)
    true
  end
end

class TrablazerPathTest < Minitest::Test
  def test_set_single_value
    # result = described_class.(params: {name: "foo"})
    # Dev.wtf?(described_class, {})
    # assert result.success?

    # params = { params: {os: "Darwin", foo: "foo"} }
    # Trailblazer::Developer.wtf?(Debugging, params)
    # result = Debugging.(params: {foo: "foo"})
    # result
  end
end
